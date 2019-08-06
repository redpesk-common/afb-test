/*
 * Copyright (C) 2016 "IoT.bzh"
 *
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

#include <string.h>
#include <mapis.h>

struct mapisHandleT {
	afb_api_t mainApiHandle;
	CtlSectionT *section;
	json_object *mapiJ;
	json_object *verbsJ;
	json_object *eventsJ;
};

static int LoadOneMapi(void *data, afb_api_t apiHandle) {
	int idx = 0;
	struct mapisHandleT *mapisHandle = (struct mapisHandleT*)data;
	CtlConfigT *ctrlConfig = afb_api_get_userdata(mapisHandle->mainApiHandle);

	afb_api_set_userdata(apiHandle, ctrlConfig);

	if(PluginConfig(apiHandle, mapisHandle->section, mapisHandle->mapiJ)) {
		AFB_API_ERROR(apiHandle, "Problem loading the plugin as an API for %s, see log message above", json_object_get_string(mapisHandle->mapiJ));
		return -1;
	}

	// declare the verbs for this API
	if(! ActionConfig(apiHandle, mapisHandle->verbsJ, 1)) {
		AFB_API_ERROR(apiHandle, "Problems at verbs creations for %s", json_object_get_string(mapisHandle->mapiJ));
		return -1;
	}

	if(mapisHandle->eventsJ) {
		// Add actions to the section to be able to respond to defined events.
		for(idx = 0; ctrlConfig->sections[idx].key != NULL; ++idx) {
			if(! strcasecmp(ctrlConfig->sections[idx].key, "events"))
				break;
		}

		if( AddActionsToSection(apiHandle, &ctrlConfig->sections[idx], mapisHandle->eventsJ, 0) ) {
			AFB_API_ERROR(apiHandle, "Wasn't able to add new events to %s", ctrlConfig->sections[idx].uid);
			return -1;
		}
	}

	// declare an event event manager for this API;
	afb_api_on_event(apiHandle, CtrlDispatchApiEvent);

	return 0;
}

static void OneMapiConfig(void *data, json_object *mapiJ) {
	const char *uid = NULL, *info = NULL;

	struct mapisHandleT *mapisHandle = (struct mapisHandleT*)data;

	if(mapiJ) {
		if(wrap_json_unpack(mapiJ, "{ss,s?s,s?s,so,s?o,so, s?o !}",
					"uid", &uid,
					"info", &info,
					"spath", NULL,
					"libs", NULL,
					"lua", NULL,
					"verbs", &mapisHandle->verbsJ,
					"events", &mapisHandle->eventsJ)) {
			AFB_API_ERROR(mapisHandle->mainApiHandle, "Wrong mapis specification, missing uid|[info]|[spath]|libs|[lua]|verbs|[events] for %s", json_object_get_string(mapiJ));
			return;
		}

		json_object_get(mapisHandle->verbsJ);
		json_object_get(mapisHandle->eventsJ);
		json_object_object_del(mapiJ, "verbs");
		json_object_object_del(mapiJ, "events");
		mapisHandle->mapiJ = mapiJ;

		if (!afb_api_new_api(mapisHandle->mainApiHandle, uid, info, 1, LoadOneMapi, (void*)mapisHandle))
			AFB_API_ERROR(mapisHandle->mainApiHandle, "Error creating new api: %s", uid);
	}
}

int MapiConfig(afb_api_t apiHandle, CtlSectionT *section, json_object *mapisJ) {
	struct mapisHandleT mapisHandle = {
		.mainApiHandle = apiHandle,
		.section = section,
		.mapiJ = NULL,
		.verbsJ = NULL
	};
	wrap_json_optarray_for_all(mapisJ, OneMapiConfig, (void*)&mapisHandle);

	return 0;
}
