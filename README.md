# pdf2png

Fast pdf to png conversion using libvips, docker, pypy

Use it like this:

```shell
curl -F "image=@file.pdf" -F "dpi=150" http://localhost:5000/image > test.png
```

### Params

* image - PDF file
* dpi - DPI (default 72)
* n - number of pages (default -1 - all pages)
* page - page number (default 0)  
