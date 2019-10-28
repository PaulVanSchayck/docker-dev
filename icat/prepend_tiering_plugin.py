#!/usr/bin/env python

# Inspired by: https://github.com/irods/irods/issues/3020, test_plugin_unified_storage_tiering

import json
import sys
import os

def main(path_to_server_config):
    with open(path_to_server_config, 'r+') as f:
        server_config = json.load(f)
        server_config['plugin_configuration']['rule_engines'].insert(0,
             {
                 "instance_name": "irods_rule_engine_plugin-unified_storage_tiering-instance",
                 "plugin_name": "irods_rule_engine_plugin-unified_storage_tiering",
                 "plugin_specific_configuration": {
                     "data_transfer_log_level" : "LOG_NOTICE"
                 }
             }
         )
        f.seek(0)
        json.dump(server_config, f, indent=4, sort_keys=True)
        f.truncate()

if __name__ == '__main__':
    if len(sys.argv) != 2:
        sys.exit('Usage: {0} path_to_server_config name_of_new_rule_to_add'.format(sys.argv[0]))
    path_to_server_config = sys.argv[1]
    main(path_to_server_config)
