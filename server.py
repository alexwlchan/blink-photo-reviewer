#!/usr/bin/env python3

import collections
import functools
import json
import os
import subprocess
import sys

from flask import Flask, redirect, render_template, request, send_file, url_for
import humanize


app = Flask(__name__)
app.config["SEND_FILE_MAX_AGE_DEFAULT"] = 24 * 60 * 60

app.add_template_filter(humanize.intcomma)


def get_asset_state(asset):
    state_albums = [
        alb
        for alb in asset["albums"]
        if alb in {"Approved", "Rejected", "Needs Action"}
    ]

    assert len(state_albums) <= 1

    asset["display_albums"] = [
        alb for alb in asset["albums"] if alb not in state_albums
    ]

    if len(state_albums) == 1:
        return state_albums[0]
    elif len(state_albums) == 0:
        return "Unknown"
    else:
        raise RuntimeError(
            f'Asset {asset["localIdentifier"]} is in multiple states: {state_albums.join(", ")}'
        )


class PhotosData:
    def __init__(self):
        self.fetch_metadata()

    def fetch_metadata(self):
        print("Fetching metadata from Photos.app...")
        data = json.loads(
            subprocess.check_output(["swift", "actions/get_structural_metadata.swift"])
        )

        all_assets = sorted(data["assets"], key=lambda a: a["creationDate"])
        self.all_positions = {
            asset["localIdentifier"]: i for i, asset in enumerate(all_assets)
        }

        all_albums = data["albums"]

        for alb in all_albums:
            alb["assetIdentifiers"] = set(alb["assetIdentifiers"])

        for asset in all_assets:
            asset["albums"] = {
                alb["localizedTitle"]
                for alb in all_albums
                if asset["localIdentifier"] in alb["assetIdentifiers"]
            }
            asset["state"] = get_asset_state(asset)

        self.all_assets = all_assets

    @functools.lru_cache(maxsize=0 if "--debug" in sys.argv else None)
    def get_response(self, local_identifier):
        all_assets = self.all_assets

        position = self.all_positions[local_identifier]

        prev_five = all_assets[position - 5 : position]
        this_asset = all_assets[position]
        next_five = all_assets[position + 1 : position + 6]

        states = collections.Counter(asset["state"] for asset in self.all_assets)

        return render_template(
            "index.html",
            assets=all_assets,
            position=position,
            prev_five=prev_five,
            this_asset=this_asset,
            next_five=next_five,
            states=states,
        )

    def run_action(self, local_identifier, action):
        subprocess.check_call(
            ["swift", "actions/run_action.swift", local_identifier, action]
        )

        this_asset = self.all_assets[self.all_positions[local_identifier]]

        if action == "toggle-favorite":
            this_asset["isFavorite"] = not this_asset["isFavorite"]
        elif action == "toggle-approved":
            this_asset["albums"].discard("Rejected")
            this_asset["albums"].discard("Needs Action")

            try:
                this_asset["albums"].remove("Approved")
            except KeyError:
                this_asset["albums"].add("Approved")
        elif action == "toggle-rejected":
            this_asset["albums"].discard("Approved")
            this_asset["albums"].discard("Needs Action")

            try:
                this_asset["albums"].remove("Rejected")
            except KeyError:
                this_asset["albums"].add("Rejected")
        elif action == "toggle-needs-action":
            this_asset["albums"].discard("Approved")
            this_asset["albums"].discard("Rejected")

            try:
                this_asset["albums"].remove("Needs Action")
            except KeyError:
                this_asset["albums"].add("Needs Action")
        elif action == "toggle-cross-stitch":
            try:
                this_asset["albums"].remove("Cross stitch")
            except KeyError:
                this_asset["albums"].add("Cross stitch")

        this_asset["state"] = get_asset_state(this_asset)

        self.get_response.cache_clear()


photos_data = PhotosData()


@app.route("/")
def index():
    try:
        local_identifier = request.args["localIdentifier"]
    except KeyError:
        all_assets = photos_data.all_assets
        return redirect(
            url_for("index", localIdentifier=all_assets[-1]["localIdentifier"])
        )

    return photos_data.get_response(local_identifier)


@functools.cache
def get_jpeg(local_identifier, *, size):
    if os.path.exists(
        f"/tmp/photos-reviewer/{local_identifier[0]}/{local_identifier}_{size}.jpg"
    ):
        return (
            f"/tmp/photos-reviewer/{local_identifier[0]}/{local_identifier}_{size}.jpg"
        )

    return subprocess.check_output(
        ["swift", "actions/get_asset_jpeg.swift", local_identifier, str(size)]
    ).decode("utf8")


@app.route("/thumbnail")
def thumbnail():
    local_identifier = request.args["localIdentifier"]

    thumbnail_path = get_jpeg(local_identifier, size=85 * 2)
    return send_file(thumbnail_path)


@app.route("/image")
def image():
    local_identifier = request.args["localIdentifier"]
    image_path = get_jpeg(local_identifier, size=2048)
    return send_file(image_path)


@app.route("/actions")
def run_action():
    local_identifier = request.args["localIdentifier"]
    action = request.args["action"]

    photos_data.run_action(local_identifier, action)

    if action in {"toggle-favorite", "toggle-cross-stitch"}:
        return redirect(url_for("index", localIdentifier=local_identifier))
    elif action in {"toggle-approved", "toggle-rejected", "toggle-needs-action"}:
        position = photos_data.all_positions[local_identifier]
        redirect_to = photos_data.all_assets[position - 1]["localIdentifier"]
        return redirect(url_for("index", localIdentifier=redirect_to))


@app.route("/open", methods=["POST"])
def open_photo():
    local_identifier = request.args["localIdentifier"]

    subprocess.check_call(
        ["osascript", "actions/open_photos_app.applescript", local_identifier]
    )

    return b"", 204


@app.route("/next-unreviewed")
def next_unreviewed():
    local_identifier = request.args['before']

    all_assets = photos_data.all_assets

    position = photos_data.all_positions[local_identifier]

    this_asset = photos_data.all_assets[position]

    unreviewed_assets = [
        asset
        for i, asset in enumerate(photos_data.all_assets)
        if i <= position and asset["state"] == "Unknown"
    ]
    try:
        next_asset_id_to_review = unreviewed_assets[-1]["localIdentifier"]
        return redirect(url_for('index', localIdentifier=next_asset_id_to_review))
    except IndexError:
        return b"", 404


@app.route("/refresh", methods=["POST"])
def refresh():
    photos_data.fetch_metadata()

    return b"", 204


if __name__ == "__main__":
    app.run(debug="--debug" in sys.argv)
