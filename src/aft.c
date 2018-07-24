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
#include <stdio.h>
#include <string.h>
#include <time.h>

#include "aft.h"
#include "mapis.h"

#define CONTROL_PREFIX "aft"
// default api to print log when apihandle not avaliable
afb_dynapi *AFB_default;
static int CtrlCreateApi(AFB_ApiT apiHandle, const char *configPath);

// Config Section definition
static CtlSectionT ctrlSections[] = {
	{.key = "resources", .loadCB = PluginConfig},
	{.key = "testVerb", .loadCB = ControlConfig},
	{.key = "events", .loadCB = EventConfig},
	{.key = "mapis", .loadCB = MapiConfig},
	{.key = NULL}
};

static void ctrlapi_ping(AFB_ReqT request) {
	static int count = 0;

	count++;
	AFB_ReqNotice(request, "Controller:ping count=%d", count);
	AFB_ReqSuccess(request, json_object_new_int(count), NULL);
}

static void ctrlapi_load(AFB_ReqT request) {
	const char *configPath = afb_req_value(request, "filepath");
	afb_api_t apiHandle = afb_req_get_api(request);

	if(!CtrlCreateApi(apiHandle, configPath))
		AFB_ReqSuccess(request, NULL, NULL);
	else
		AFB_ReqFailF(request, "Error", "Not able to load test API with the configuration file: %s", configPath);
}

static void ctrlapi_exit(AFB_ReqT request) {
	AFB_ReqNotice(request, "Exiting...");
	AFB_ReqSuccess(request, NULL, NULL);
	exit(0);
}

static AFB_ApiVerbs CtrlApiVerbs[] = {
	/* VERB'S NAME         FUNCTION TO CALL         SHORT DESCRIPTION */
	{.verb = "ping", .callback = ctrlapi_ping, .info = "ping test for API"},
	{.verb = "load", .callback = ctrlapi_load, .info = "load a API meant to launch test for a binding"},
	{.verb = "exit", .callback = ctrlapi_exit, .info = "Exit test"},
	{.verb = NULL} /* marker for end of the array */
};

static int CtrlLoadStaticVerbs(afb_dynapi *apiHandle, AFB_ApiVerbs *verbs) {
	int errcount = 0;

	for(int idx = 0; verbs[idx].verb; idx++) {
		errcount += afb_dynapi_add_verb(
				apiHandle, CtrlApiVerbs[idx].verb, NULL, CtrlApiVerbs[idx].callback,
				(void *)&CtrlApiVerbs[idx], CtrlApiVerbs[idx].auth, 0);
	}

	return errcount;
};

static int CtrlInitOneApi(AFB_ApiT apiHandle) {
	// Hugely hack to make all V2 AFB_DEBUG to work in fileutils
	AFB_default = apiHandle;

	CtlConfigT *ctrlConfig = afb_dynapi_get_userdata(apiHandle);

	return CtlConfigExec(apiHandle, ctrlConfig);
}

// next generation dynamic API-V3 mode
#include <signal.h>

static int CtrlLoadOneApi(void *cbdata, AFB_ApiT apiHandle) {
	CtlConfigT *ctrlConfig = (CtlConfigT *)cbdata;

	// save closure as api's data context
	afb_dynapi_set_userdata(apiHandle, ctrlConfig);

	// add static controls verbs
	int err = CtrlLoadStaticVerbs(apiHandle, CtrlApiVerbs);
	if(err) {
		AFB_ApiError(apiHandle, "CtrlLoadSection fail to register static V2 verbs");
		return ERROR;
	}

	// load section for corresponding API
	err = CtlLoadSections(apiHandle, ctrlConfig, ctrlSections);

	// declare an event event manager for this API;
	afb_dynapi_on_event(apiHandle, CtrlDispatchApiEvent);

	// init API function (does not receive user closure ???
	afb_dynapi_on_init(apiHandle, CtrlInitOneApi);

	afb_dynapi_seal(apiHandle);
	return err;
}

static int CtrlCreateApi(AFB_ApiT apiHandle, const char *configPath) {
	int err = 0;
	json_object *resourcesJ = NULL, *eventsJ = NULL;
	CtlConfigT *ctrlConfig = NULL;
// load config file and create API
	ctrlConfig = CtlLoadMetaDataUsingPrefix(apiHandle, configPath, CONTROL_PREFIX);
	if(!ctrlConfig) {
		AFB_ApiError(apiHandle,
			"CtrlBindingDyn No valid control config file in:\n-- %s",
			configPath);
		return ERROR;
	}

	if(!ctrlConfig->api) {
		AFB_ApiError(apiHandle,
			"CtrlBindingDyn API Missing from metadata in:\n-- %s",
			configPath);
		return ERROR;
	}

	AFB_ApiNotice(apiHandle, "Controller API='%s' info='%s'", ctrlConfig->api,
			ctrlConfig->info);

	err = wrap_json_pack(&resourcesJ, "{s[{ss, ss, ss}]}", "resources",
		"uid", "AFT",
		"info", "LUA Binder test framework",
		"libs", "aft.lua" );
	err += wrap_json_pack(&eventsJ, "{s[{ss, ss}]}", "events",
		"uid", "monitor/trace",
		"action", "lua://AFT#_evt_catcher_" );

	if(err) {
		AFB_ApiError(apiHandle, "Error at Controller configuration editing.");
		return err;
	}
	wrap_json_object_add(ctrlConfig->configJ, resourcesJ);
	wrap_json_object_add(ctrlConfig->configJ, eventsJ);

	err = afb_dynapi_new_api(apiHandle, ctrlConfig->api, ctrlConfig->info, 1, CtrlLoadOneApi, ctrlConfig);

	return err;
}

int afbBindingEntry(afb_dynapi *apiHandle) {
	size_t len = 0;
	char *dirList;
	const char *envDirList = NULL, *configPath = NULL;
	AFB_default = apiHandle;

	AFB_ApiNotice(apiHandle, "Controller in afbBindingEntry");

	envDirList = getEnvDirList(CONTROL_PREFIX, "CONFIG_PATH");

	if(envDirList) {
		len = strlen(CONTROL_CONFIG_PATH) + strlen(envDirList);
		dirList = malloc(len + 1);
		snprintf(dirList, len + 1, "%s:%s", envDirList, CONTROL_CONFIG_PATH);
	}
	else {
		dirList = CONTROL_CONFIG_PATH;
	}

	configPath = CtlConfigSearch(apiHandle, dirList, CONTROL_PREFIX);
	if(!configPath) {
		AFB_ApiError(apiHandle, "CtlPreInit: No %s* config found in %s ", GetBinderName(), dirList);
		return ERROR;
	}

	return CtrlCreateApi(apiHandle, configPath);
}