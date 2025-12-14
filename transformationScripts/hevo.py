from io.hevo.api import Event

"""
event: each record streaming through Hevo pipeline is an event

returns: 
    - The modified event object.
    - Array of event objects if new events are generated from the incoming event.
    - None if the event is supposed to be dropped from the pipeline.

Read complete documentation at: https://docs.hevodata.com/pipelines/transformations/
"""


def transform(event):
        
    events = []

    event_name = event.getEventName()
    properties = event.getProperties()

    # -----------------------------------
    # 1. ORDERS → ORDER_EVENTS
    # -----------------------------------
    if event_name == "orders":
        status = properties.get("status")

        status_to_event = {
            "placed": "order_placed",
            "shipped": "order_shipped",
            "delivered": "order_delivered",
            "cancelled": "order_cancelled"
        }

        if status in status_to_event:
            order_event_props = {
                "order_id": properties.get("id"),
                "customer_id": properties.get("customer_id"),
                "event_type": status_to_event[status]
            }

            events.append(Event("order_events", order_event_props))

        # Optional: keep original orders table
        events.append(Event("orders", properties))

    # -----------------------------------
    # 2. CUSTOMERS → ADD USERNAME
    # -----------------------------------
    elif event_name == "customers":
        email = properties.get("email")
        
        
        if email and "@" in email:
            properties["username"] = email.split("@")[0]

        events.append(Event("customers", properties))

    # -----------------------------------
    # 3. ALL OTHER EVENTS (feedback, etc.)
    # -----------------------------------
    else:
        events.append(Event(event_name, properties))

    return events