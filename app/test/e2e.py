import requests

# Set the base URL for the API
# base_url = "http://localhost:8090"
base_url = "http://cicdlab.mooo.com:8090"

def test_e2e():
    # Perform the end-to-end tests
    
    # Test POST (add an actor)
    actor_id = add_actor()
    
    # Test GET (retrieve the actor)
    actor = get_actor(actor_id)
    print_result("GET actor", actor is not None)
    
    # Test DELETE (delete the actor)
    delete_actor(actor_id)
    
    # Test GET (retrieve the actor after deletion)
    actor = get_actor(actor_id)
    print_result("GET deleted actor", actor is None)

def add_actor():
    # Add an actor using a POST request
    
    endpoint = "/actors"
    url = base_url + endpoint
    
    data = {
        "actor_id": "10859",
        "name": "Ryan Reynolds"
    }
    
    response = requests.post(url, json=data)
    actor_id = None
    if response.status_code == 201:
        result = response.json()
        actor_id = result.get("actor_id")
    print_result("POST actor", actor_id is not None)
    
    return actor_id

def get_actor(actor_id):
    # Retrieve an actor using a GET request
    
    endpoint = f"/actors/{actor_id}"
    url = base_url + endpoint
    
    response = requests.get(url)
    actor = None
    if response.status_code == 200:
        actor = response.json().get("data")
    
    return actor

def delete_actor(actor_id):
    # Delete an actor using a DELETE request
    
    endpoint = f"/actors/{actor_id}"
    url = base_url + endpoint
    
    response = requests.delete(url)
    print_result("DELETE actor", response.status_code == 204)

def print_result(test_name, result):
    # Print the result of a test step
    if result:
        print(f"{test_name}: PASS")
    else:
        print(f"{test_name}: FAIL")
        raise Exception(f"{test_name} failed. Exiting...")

# Run the end-to-end tests
test_e2e()
