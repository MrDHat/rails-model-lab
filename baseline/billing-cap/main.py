"""Stops every VM in the project once the budget's cost reaches its amount.

The budget publishes its current cost to Pub/Sub several times a day. Billing
data lags by hours, so the cap leaves room below the remaining credit.
"""
import base64
import json
import os

import functions_framework
from google.cloud import compute_v1

PROJECT = os.environ["PROJECT"]
ACTIVE = {"PROVISIONING", "STAGING", "RUNNING"}


@functions_framework.cloud_event
def stop_on_cap(event):
    budget = json.loads(base64.b64decode(event.data["message"]["data"]))
    cost, cap = budget["costAmount"], budget["budgetAmount"]
    print(f"cost {cost} of {cap} {budget['currencyCode']}")
    if cost < cap:
        return
    instances = compute_v1.InstancesClient()
    for zone, scoped in instances.aggregated_list(project=PROJECT):
        for vm in scoped.instances:
            if vm.status in ACTIVE:
                print(f"cap reached: stopping {vm.name} in {zone}")
                instances.stop(project=PROJECT, zone=zone.split("/")[-1], instance=vm.name)
