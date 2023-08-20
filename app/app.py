from flask import Flask, render_template, request, jsonify
from pymongo import MongoClient
import requests
import logging
from prometheus_client import generate_latest, CONTENT_TYPE_LATEST, Counter
import os

API_KEY = os.environ.get("API_KEY")
app = Flask(__name__)


# Configure the logging
logging.basicConfig(filename='app.log', level=logging.INFO)

# Create a Prometheus counter for the /actor/search endpoint
actor_search_counter = Counter(
    'actor_search_counter', 'Number of times the /actor/search endpoint has been accessed')

# Connect to the MongoDB server
db_name = os.environ.get("MONGODB_DATABASE")
db_host = os.environ.get("MONGODB_HOST")
db_port = os.environ.get("MONGODB_PORT")
db_user = os.environ.get("MONGODB_USERNAME")
db_password = os.environ.get("MONGODB_PASSWORD")
db_uri = f'mongodb://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}'

client = MongoClient(f'{db_uri}')

db = client[f'{db_name}']
credits_collection = db['credits']


@app.route('/health')
def health():
    return jsonify({"status": "Ok"})


@app.route('/metrics')
def metrics():
    # Generate and return metrics
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}


@app.route('/', methods=["GET", "POST"])
def search():

    if request.method == "POST":

        try:

            # search actor from api.themoviedb
            query = request.form["query"]
            actor = get_actor_data_by_name(query)

            return render_template('index.html', actor=actor, is_search=True)

        except Exception as ex:
            return jsonify(
                {
                    "success": False,
                    "message": f"{ex}"
                }
            ), 500

    else:
        # load search page
        return render_template('index.html', is_search=True)


@app.route('/favorite', methods=["GET", "POST"])
def favorite():
    # load favorite page
    return render_template('favorite.html', is_favorite=True)


@app.route('/actors', methods=['GET', 'POST'])
def actors():

    try:

        # Create new actor and return actor_id
        if request.method == 'POST':

            # Load actor by id from  api.themoviedb
            # and save it into cineindex mongodb

            data_json = request.get_json()
            actor_id = data_json['actor_id']
            name = data_json['name']

            # Check if actor exist
            actor_exist_data = credits_collection.find_one({"_id": actor_id})
            if actor_exist_data:
                return jsonify({
                    "success": False,
                    "message": "Actor exist in your favorite list",
                    "actor_id": actor_id
                }), 204

            url = f'https://api.themoviedb.org/3/person/{actor_id}/movie_credits?api_key={API_KEY}&language=en-US'
            response = requests.get(url)
            movie_data = response.json()
            actor_data = get_actor_data_by_name(name)

            # format data
            filtered_data = [
                {

                    'original_title': movie.get('original_title', ''),
                    'overview': movie.get('overview', ''),
                    'poster_path': movie.get('poster_path', ''),
                    'release_date': movie.get('release_date', ''),
                    'title': movie.get('title', ''),
                    'character': movie.get('character', '')

                } for movie in movie_data['cast']]

            # Save filtered_data to MongoDB
            result = credits_collection.insert_one(
                {
                    '_id': actor_id,
                    'actor_id': actor_id,
                    'movie_credits': filtered_data,
                    'actor_data': actor_data
                })

            # Return actor_id and 201 status code
            return jsonify({
                "success": True,
                "actor_id": result.inserted_id
            }), 201

        elif request.method == 'GET':
            # Load all actors record

            actors_query = credits_collection.find({})
            actors = [actor for actor in actors_query]
            return jsonify({
                "success": True,
                "data": actors
            })

    except Exception as ex:
        print(str(ex))
        return jsonify({
            "success": True,
            "message": f"{ex}"
        }), 500


def get_actor_data_by_name(name):
    # Retrive actor detail and return result

    url = f'http://api.tmdb.org/3/search/person?api_key={API_KEY}&query={name}'

    response = requests.get(url)
    data = response.json()

    filtered_data = {
        'id': data['results'][0]['id'],
        'gender': data['results'][0]['gender'],
        'profile_path': data['results'][0]['profile_path'],
        'name': data['results'][0]['name']
    }

    return filtered_data


@app.route('/actors/<string:actor_id>', methods=['GET', 'PUT', 'DELETE'])
def actor_detail(actor_id):
    # Get, update and delete actor

    try:

        if request.method == 'GET':

            # Retrieve actor from database
            actor = credits_collection.find_one({"_id": actor_id})
            return jsonify({
                "success": True,
                "data": actor
            })

        elif request.method == 'PUT':
            # update actor detail

            new_data = request.get_json()

            credits_data = credits_collection.find_one({"_id": actor_id})

            # Get actor_data
            actor_data = credits_data['actor_data']

            # update name and gender
            actor_data['name'] = new_data["name"]

            # Update actor credit with actor details
            credits_data['actor_data'] = actor_data

            # Update database with actor credit
            credits_collection.update_one(
                {"_id": actor_id}, {"$set": credits_data})

            # Return actor_id and 201 status code
            return jsonify({
                "success": True,
                "actor_id": actor_id
            }), 200

        elif request.method == 'DELETE':
            # Delete actor by id and return id
            credits_collection.delete_one({"_id": actor_id})

            return jsonify({
                "success": True,
                "actor_id": actor_id
            }), 204

    except Exception as ex:
        print(str(ex))
        # Return error massage
        return jsonify(
            {
                "succes": False,
                "message": f"{ex}"
            }
        ), 500


PORT = os.environ.get("APP_PORT", 8080)
if __name__ == '__main__':
    app.run(host="0.0.0.0", port=PORT)
