from flask import Flask
from flask import request
from flask import send_file
import pyvips
import io
import os
from tempfile import mkstemp

app = Flask(__name__)

@app.route("/")
def hello():
    return "Use /image endpoint"

@app.route("/image", methods=['POST'])
def image():
    f = request.files.get('image')
    if f:
        page = request.form.get('page', 0)
        n = request.form.get('n', -1)
        dpi = request.form.get('dpi', 72)
        tmpfile = mkstemp('.pdf')
        f.save(tmpfile[1])
        os.close(tmpfile[0])
        try:
            image = pyvips.Image.pdfload(tmpfile[1], page=int(page), n=int(n), dpi=int(dpi))
            os.remove(tmpfile[1])
            if request.form.get('grayscale'):
                image = image.colourspace('b-w')
            a = image.write_to_buffer('.png')   
            return send_file(io.BytesIO(a), mimetype='image/png')
        except:
            os.remove(tmpfile[1])
            return "Something went wrong", 500
            
    else:
        return "Please provide input pdf file"