#!/usr/bin/env python3

import functools
import json
import subprocess
import sys

from flask import Flask, redirect, render_template, request, send_file, url_for


app = Flask(__name__)
app.config['SEND_FILE_MAX_AGE_DEFAULT'] = 24 * 60 * 60


def get_asset_state(asset):
    state_albums = [alb for alb in asset['albums'] if alb in {'Flagged', 'Rejected', 'Needs Action'}]

    assert len(state_albums) <= 1

    asset['display_albums'] = [alb for alb in asset['albums'] if alb not in state_albums]

    if len(state_albums) == 1:
        return state_albums[0]
    elif len(state_albums) == 0:
        return 'Unknown'
    else:
        raise RuntimeError(f'Asset {asset["localIdentifier"]} is in multiple states: {state_albums.join(", ")}')


class PhotosData:
    def __init__(self):
        data = json.loads(subprocess.check_output(['swift', 'get_structural_metadata.swift']))

        all_assets = sorted(data['assets'], key=lambda a: a['creationDate'])
        self.all_positions = {asset['localIdentifier']: i for i, asset in enumerate(all_assets)}

        all_albums = data['albums']

        for alb in all_albums:
            alb['assetIdentifiers'] = set(alb['assetIdentifiers'])

        for asset in all_assets:
            asset['albums'] = {alb['localizedTitle'] for alb in all_albums if asset['localIdentifier'] in alb['assetIdentifiers']}
            asset['state'] = get_asset_state(asset)

        self.all_assets = all_assets

    @functools.lru_cache(maxsize=0 if '--debug' in sys.argv else None)
    def get_response(self, local_identifier):
        all_assets = self.all_assets

        position = self.all_positions[local_identifier]

        prev_five = all_assets[position - 5:position]
        this_asset = all_assets[position]
        next_five = all_assets[position + 1:position + 6]

        return render_template('index.html', assets=all_assets, position=position, prev_five=prev_five, this_asset=this_asset, next_five=next_five)

    def flag(self, local_identifier):
        subprocess.check_call(['swift', 'scripts/flag.swift', local_identifier])

        this_asset = self.all_assets[self.all_positions[local_identifier]]

        try:
            this_asset['albums'].remove('Rejected')
        except KeyError:
            pass

        try:
            this_asset['albums'].remove('Needs Action')
        except KeyError:
            pass

        this_asset['albums'].add('Flagged')

        this_asset['state'] = get_asset_state(this_asset)

        self.get_response.cache_clear()

    def reject(self, local_identifier):
        subprocess.check_call(['swift', 'scripts/reject.swift', local_identifier])

        this_asset = self.all_assets[self.all_positions[local_identifier]]

        try:
            this_asset['albums'].remove('Flagged')
        except KeyError:
            pass

        try:
            this_asset['albums'].remove('Needs Action')
        except KeyError:
            pass

        this_asset['albums'].add('Rejected')

        this_asset['state'] = get_asset_state(this_asset)

        self.get_response.cache_clear()

    def needs_action(self, local_identifier):
        subprocess.check_call(['swift', 'scripts/needs_action.swift', local_identifier])

        this_asset = self.all_assets[self.all_positions[local_identifier]]

        try:
            this_asset['albums'].remove('Flagged')
        except KeyError:
            pass

        try:
            this_asset['albums'].remove('Rejected')
        except KeyError:
            pass

        this_asset['albums'].add('Needs Action')

        this_asset['state'] = get_asset_state(this_asset)

        self.get_response.cache_clear()





photos_data = PhotosData()


@app.route("/")
def index():
    try:
        local_identifier = request.args['localIdentifier']
    except KeyError:
        all_assets = photos_data.all_assets
        return redirect(url_for('index', localIdentifier=all_assets[-1]['localIdentifier']))

    return photos_data.get_response(local_identifier)


@functools.cache
def get_thumbnail_path(local_identifier):
    # 85 * 2x
    return subprocess.check_output(['swift', 'get_asset_jpeg.swift', local_identifier, '170']).decode('utf8')


@app.route('/thumbnail')
def thumbnail():
    local_identifier = request.args['localIdentifier']
    thumbnail_path = get_thumbnail_path(local_identifier)
    return send_file(thumbnail_path)


@functools.cache
def get_image_path(local_identifier):
    return subprocess.check_output(['swift', 'get_asset_jpeg.swift', local_identifier, '2048']).decode('utf8')


@app.route('/actions/flag')
def flag():
    local_identifier = request.args['localIdentifier']

    photos_data.flag(local_identifier)

    return redirect(url_for('index', localIdentifier=local_identifier))


@app.route('/actions/reject')
def reject():
    local_identifier = request.args['localIdentifier']

    photos_data.reject(local_identifier)

    return redirect(url_for('index', localIdentifier=local_identifier))


@app.route('/actions/needs_action')
def needs_action():
    local_identifier = request.args['localIdentifier']

    photos_data.needs_action(local_identifier)

    return redirect(url_for('index', localIdentifier=local_identifier))




@app.route('/image')
def image():
    local_identifier = request.args['localIdentifier']
    image_path = get_image_path(local_identifier)
    return send_file(image_path)


if __name__ == '__main__':
    app.run(debug="--debug" in sys.argv)
