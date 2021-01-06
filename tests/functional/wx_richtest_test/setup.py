from distutils.core import setup
import py2exe

setup( console=[{ "script": "wx_richtext_test.py",},],
       options={"py2exe": {
              "includes":['imp'],
       }})
