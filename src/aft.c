/*
* Copyright (C) 2016 "IoT.bzh"
* Author Fulup Ar Foll <fulup@iot.bzh>
* Author Romain Forlot <romain@iot.bzh>
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*   http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

#define _GNU_SOURCE
#include <pthread.h>
#include <string.h>
#include <systemd/sd-event.h>

#include "aft.h"
#include "mapis.h"

#define CONTROL_PREFIX "aft"

static CtlConfigT *CtrlLoadConfigJson(afb_api_t apiHandle, json_object *configJ);
static CtlConfigT *CtrlLoadConfigFile(afb_api_t apiHandle, const char *configPath);
static int CtrlCreateApi(afb_api_t apiHandle, CtlConfigT *ctrlConfig);
static pthread_mutex_t memo_lock;
static afb_req_t memo_sync = NULL;
static struct sd_event_source *timersrc = NULL;

static void onTraceEvent(void *closure, const char *event, json_object *data, afb_api_t api) {
	/* If LUA evt Handler return 0 then stop the waiting sync request else
	 * do nothing and continue to wait for every requested event to arrive.
	 */
	pthread_mutex_lock(&memo_lock);
	if(memo_sync) {
		afb_req_reply(memo_sync, json_object_get(data), NULL, event);
		afb_req_unref(memo_sync);
		memo_sync = NULL;
	}
	pthread_mutex_unlock(&memo_lock);
}

// Config Section definition
static CtlSectionT ctrlSections[] = {
	{.key = "resources", .loadCB = PluginConfig},
	{.key = "testVerb", .loadCB = ControlConfig},
	{.key = "events", .loadCB = EventConfig},
	{.key = "mapis", .loadCB = MapiConfig},
	{.key = NULL}
};

static void ctrlapi_ping(afb_req_t request) {
	static int count = 0;

	count++;
	AFB_REQ_NOTICE(request, "Controller:ping count=%d", count);
	afb_req_success(request, json_object_new_int(count), NULL);
}

static void ctrlapi_load(afb_req_t request) {
	const char *configPath = NULL;
	json_object *reqArgs = afb_req_json(request), *configuration = NULL ;
	afb_api_t apiHandle = afb_req_get_api(request);

	if(!json_object_object_get_ex(reqArgs, "configuration", &configuration)) {
		afb_req_fail_f(request, "Error", "No 'configuration' key found in request arguments: %s", json_object_get_string(reqArgs));
		return;
	}

	switch(json_object_get_type(configuration)) {
		case json_type_string:
			configPath = json_object_get_string(configuration);
			if(CtrlCreateApi(apiHandle, CtrlLoadConfigFile(apiHandle, configPath)))
				afb_req_fail_f(request, "Error", "Not able to load test API with the file: %s", configPath);
			else
				afb_req_success(request, NULL, NULL);
			break;
		case json_type_object:
			if(CtrlCreateApi(apiHandle, CtrlLoadConfigJson(apiHandle, configuration)))
				afb_req_fail_f(request, "Error", "Not able to load test API with the JSON: %s", json_object_get_string(configuration));
			else
				afb_req_success(request, NULL, NULL);
			break;
		default:
			afb_req_fail_f(request, "Error", "the found JSON isn't valid type, it should be a string indicating a filepath to the JSON to load or an object representing the configuration. We got: %s", json_object_get_string(configuration));
			break;
	}
}

static void ctrlapi_exit(afb_req_t request) {
	AFB_REQ_NOTICE(request, "Exiting...");
	pthread_mutex_destroy(&memo_lock);
	afb_req_success(request, NULL, NULL);
	exit(0);
}

static int timeoutCB(struct sd_event_source *s, uint64_t us, void *ud)
{
	afb_req_t req;

	pthread_mutex_lock(&memo_lock);
	req = memo_sync;
	memo_sync = NULL;
	sd_event_source_unref(timersrc);
	timersrc = NULL;
	pthread_mutex_unlock(&memo_lock);

	if(req) {
		afb_req_reply(req, NULL, "timeout", NULL);
		afb_req_unref(req);
	}

	return 0;
}

/**
 * @brief A verb to call synchronously that will end when a timeout expires or
 * when a call with a 'stop' order given in the arguments.
 *
 * @param request: the AFB request object
 */
static void ctrlapi_sync(afb_req_t request) {
	struct json_object *obj, *val;
	uint64_t timeout, usec;

	AFB_REQ_DEBUG(request, "Syncing...");
	obj = afb_req_json(request);

	pthread_mutex_lock(&memo_lock);
	if(json_object_object_get_ex(obj, "start", &val) &&
	    (timeout = json_object_get_int(val)) &&
	    ! memo_sync) {
		sd_event_now(afb_api_get_event_loop(afb_req_get_api(request)), CLOCK_MONOTONIC, &usec);
		usec = timeout + usec;
		sd_event_add_time(afb_api_get_event_loop(afb_req_get_api(request)), &timersrc, CLOCK_MONOTONIC, usec, 0, timeoutCB, NULL);
		memo_sync = afb_req_addref(request);
	} else if(json_object_object_get_ex(obj, "continue", &val) && ! memo_sync) {
		memo_sync = afb_req_addref(request);
	} else if(json_object_object_get_ex(obj, "stop", &val) && timersrc) {
		if(memo_sync) {
			afb_req_reply(request, NULL, NULL, "Unfinished start request ended");
			afb_req_unref(memo_sync);
			memo_sync = NULL;
		}
		sd_event_source_set_enabled(timersrc, SD_EVENT_OFF);
		sd_event_source_unref(timersrc);
		afb_req_reply(request, NULL, NULL, "stopped");
		timersrc = NULL;
	} else {
		if(memo_sync) {
			afb_req_reply(request, NULL, "Bad State", "Unfinished start request ended");
			afb_req_unref(memo_sync);
			memo_sync = NULL;
		}
		afb_req_reply(request, NULL, "Bad state", NULL);
	}
	pthread_mutex_unlock(&memo_lock);
}

static afb_verb_t CtrlApiVerbs[] = {
	/* VERB'S NAME         FUNCTION TO CALL         SHORT DESCRIPTION */
	{.verb = "ping", .callback = ctrlapi_ping, .info = "ping test for API"},
	{.verb = "load", .callback = ctrlapi_load, .info = "load a API meant to launch test for a binding"},
	{.verb = "exit", .callback = ctrlapi_exit, .info = "Exit test"},
	{.verb = "sync", .callback = ctrlapi_sync, .info = "Manually make a sync for something using a synchronous subcall"},
	{.verb = NULL} /* marker for end of the array */
};

static int CtrlLoadStaticVerbs(afb_api_t apiHandle, afb_verb_t *verbs) {
	int errcount = 0;

	for(int idx = 0; verbs[idx].verb; idx++) {
		errcount += afb_api_add_verb(
				apiHandle, CtrlApiVerbs[idx].verb, NULL, CtrlApiVerbs[idx].callback,
				(void *)&CtrlApiVerbs[idx], CtrlApiVerbs[idx].auth, 0, 0);
	}

	return errcount;
};

static int CtrlInitOneApi(afb_api_t apiHandle) {
	CtlConfigT *ctrlConfig = afb_api_get_userdata(apiHandle);

	return CtlConfigExec(apiHandle, ctrlConfig);
}

static int CtrlLoadOneApi(void *cbdata, afb_api_t apiHandle) {
	CtlConfigT *ctrlConfig = (CtlConfigT *)cbdata;

	if(pthread_mutex_init(&memo_lock, NULL)) {
		AFB_API_ERROR(apiHandle, "Fail to initialize");
		return -1;
	}

	// save closure as api's data context
	afb_api_set_userdata(apiHandle, ctrlConfig);

	// add static controls verbs
	int err = CtrlLoadStaticVerbs(apiHandle, CtrlApiVerbs);
	if(err) {
		AFB_API_ERROR(apiHandle, "CtrlLoadSection fail to register static V2 verbs");
		return ERROR;
	}

	// load section for corresponding API
	err = CtlLoadSections(apiHandle, ctrlConfig, ctrlSections);

	// declare an event event manager for this API;
	afb_api_event_handler_add(apiHandle, "monitor/trace", onTraceEvent, NULL);

	// init API function (does not receive user closure ???
	afb_api_on_init(apiHandle, CtrlInitOneApi);

	afb_api_seal(apiHandle);
	return err;
}

static CtlConfigT *CtrlLoadConfigJson(afb_api_t apiHandle, json_object *configJ) {
	return CtlLoadMetaDataJson(apiHandle, configJ, CONTROL_PREFIX);
}

static CtlConfigT *CtrlLoadConfigFile(afb_api_t apiHandle, const char *configPath) {
	return CtlLoadMetaDataUsingPrefix(apiHandle, configPath, CONTROL_PREFIX);
}

static int CtrlCreateApi(afb_api_t apiHandle, CtlConfigT *ctrlConfig) {
	int err = 0;
	json_object *resourcesJ = NULL;

	if(!ctrlConfig) {
		AFB_API_ERROR(apiHandle,
			"CtrlBindingDyn No valid control config file loaded.");
			return ERROR;
	}

	if(!ctrlConfig->api) {
		AFB_API_ERROR(apiHandle,
			"CtrlBindingDyn API Missing from metadata in:\n-- %s",
			json_object_get_string(ctrlConfig->configJ));
		return ERROR;
	}

	AFB_API_NOTICE(apiHandle, "Controller API='%s' info='%s'", ctrlConfig->api,
			ctrlConfig->info);

	err = wrap_json_pack(&resourcesJ, "{s[{ss, ss, ss}]}", "resources",
		"uid", "AFT",
		"info", "LUA Binder test framework",
		"libs", "aft.lua" );

	if(err) {
		AFB_API_ERROR(apiHandle, "Error at Controller configuration editing.");
		return err;
	}
	wrap_json_object_add(ctrlConfig->configJ, resourcesJ);

	if(! afb_api_new_api(apiHandle, ctrlConfig->api, ctrlConfig->info, 0, CtrlLoadOneApi, ctrlConfig))
		return ERROR;

	return 0;
}

int afbBindingEntry(afb_api_t apiHandle) {
	size_t len = 0, bindingRootDirLen = 0;
	char *dirList, *afTestRootDir, *path;
	const char *envDirList = NULL, *configPath = NULL, *bindingRootDir = NULL;
	json_object *settings = afb_api_settings(apiHandle), *bpath = NULL;
	CtlConfigT *ctrlConfig = NULL;

	AFB_API_DEBUG(apiHandle, "Controller in afbBindingEntry");

	if(json_object_object_get_ex(settings, "binding-path", &bpath)) {
		afTestRootDir = strdup(json_object_get_string(bpath));
		path = rindex(afTestRootDir, '/');
		if(strlen(path) < 3)
			return ERROR;
		*++path = '.';
		*++path = '.';
		*++path = '\0';
	}
	else {
		afTestRootDir = malloc(1);
		strcpy(afTestRootDir, "");
	}

	envDirList = getEnvDirList(CONTROL_PREFIX, "CONFIG_PATH");

	bindingRootDir = GetBindingDirPath(apiHandle);
	bindingRootDirLen = strlen(bindingRootDir);

	if(envDirList) {
		len = strlen(CONTROL_CONFIG_PATH) + strlen(envDirList) + bindingRootDirLen + 3;
		dirList = malloc(len + 1);
		snprintf(dirList, len +1, "%s:%s:%s:%s", envDirList, afTestRootDir, bindingRootDir, CONTROL_CONFIG_PATH);
	}
	else {
		len = strlen(CONTROL_CONFIG_PATH) + bindingRootDirLen + 2;
		dirList = malloc(len + 1);
		snprintf(dirList, len + 1, "%s:%s:%s", bindingRootDir, afTestRootDir, CONTROL_CONFIG_PATH);
	}

	configPath = CtlConfigSearch(apiHandle, dirList, CONTROL_PREFIX);
	if(!configPath) {
		AFB_API_ERROR(apiHandle, "CtlPreInit: No %s-%s* config found in %s ", CONTROL_PREFIX, GetBinderName(), dirList);
		return ERROR;
	}

	ctrlConfig = CtrlLoadConfigFile(apiHandle, configPath);
	free(afTestRootDir);
	free(dirList);
	return CtrlCreateApi(apiHandle, ctrlConfig);
}
