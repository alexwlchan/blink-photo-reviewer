This folder contains all the code that actually interacts with the Photos library.
If you're building your own project to interact with Photos, some of this might be useful/reusable.

These scripts are built around [PHObject.localIdentifier], a persistent string that identifies objects (and assets in particular).
In my experience, these identifiers are a UUID with some trailing info, e.g. `F011D947-B547-4FFC-92A1-31D197B5EF4E/L0/001`.

[PHObject.localIdentifier]: https://developer.apple.com/documentation/photokit/phobject/1622400-localidentifier

The scripts are as follows:

<dl>
  <dt><code>get_asset_jpeg.swift [LOCAL_IDENTIFIER] [SIZE]</code></dt>
  <dd>
    get a JPEG for a photo in my library.
    It prints a path to the generated file.
    <br/><br/>
    This includes downloading the photo from iCloud Photo Library, if it isn’t already saved locally.
    There are two potentially interesting functions in here: one to create an NSImage from a PHAsset, one to convert an NSImage into JPEG Data.
  </dd>

  <dt><code>get_structural_metadata.swift</code></dt>
  <dd>
    extract a bunch of information about my albums and assets, and print it as a JSON object.
  </dd>

  <dt><code>open_photos_app.applescript [LOCAL_IDENTIFIER]</code></dt>
  <dd>
    open the given photo in Photos.app.
  </dd>

  <dt><code>run_action.swift [LOCAL_IDENTIFIER] [ACTION_NAME]</code></dt>
  <dd>
    this script does all the modification of stuff in Photos.app.
    This includes marking a photo as a favourite and adding/removing photos from albums.
    <br/><br/>
    This could be a bunch of separate scripts, but I collapsed them into a single script because there was a lot of similar code.
  </dd>
</dl>