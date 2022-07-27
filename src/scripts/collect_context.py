#!/usr/bin/env python

import json
import os
import sys

target_dir = os.path.join("sym", "context")
if not os.path.exists(target_dir):
    sys.exit(0)

data = {}
for path in os.listdir(target_dir):
    full_path = os.path.join(target_dir, path)
    if os.path.isfile(full_path):
        with open(full_path, "r") as f:
            data[path] = f.read().rstrip()

target_path = os.path.join("sym", "context.json")
with open(target_path, "w") as target:
    json.dump(data, target)
print(f"Added context to {target_path}")
