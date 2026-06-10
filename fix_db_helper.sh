#!/bin/bash
sed -i 's/Directory documentsDirectory = await getApplicationDocumentsDirectory();/Directory documentsDirectory = Directory.systemTemp;/g' app_islamic_v2/lib/core/db/db_helper.dart
