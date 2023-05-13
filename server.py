#!/usr/bin/env python3

import functools
import json
import subprocess

from flask import Flask, redirect, render_template, request, send_file, url_for


app = Flask(__name__)
app.config['SEND_FILE_MAX_AGE_DEFAULT'] = 24 * 60 * 60


@app.route("/")
def index():
    data = json.load(open('out.json'))

    all_assets = sorted(data['assets'], key=lambda a: a['creationDate'])

    try:
        local_identifier = request.args['localIdentifier']
    except KeyError:
        return redirect(url_for('index', localIdentifier=all_assets[-1]['localIdentifier']))

    position = next(i for i, asset in enumerate(all_assets) if asset['localIdentifier'] == local_identifier)

    prev_five = all_assets[position - 5:position]
    this_asset = all_assets[position]
    next_five = all_assets[position + 1:position + 6]

    return render_template('index.html', assets=all_assets, position=position, prev_five=prev_five, this_asset=this_asset, next_five=next_five)


@functools.cache
def get_thumbnail_path(local_identifier):
    return subprocess.check_output(['swift', 'get_asset_jpeg.swift', local_identifier, '65']).decode('utf8')


@app.route('/thumbnail')
def thumbnail():
    local_identifier = request.args['localIdentifier']
    thumbnail_path = get_thumbnail_path(local_identifier)
    return send_file(thumbnail_path)


@functools.cache
def get_image_path(local_identifier):
    return subprocess.check_output(['swift', 'get_asset_jpeg.swift', local_identifier, '2048']).decode('utf8')


@app.route('/image')
def image():
    local_identifier = request.args['localIdentifier']
    image_path = get_image_path(local_identifier)
    return send_file(image_path)


if __name__ == '__main__':
    app.run(debug=True)
