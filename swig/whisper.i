%module Whisper 
%{
#include "whisper.h"
%}
%include "stdint.i"
%include "cpointer.i"
%include "carrays.i"
%include "typemaps.i"

%array_class(float, FloatArray);
%array_class(int, IntArray);
%array_class(char, ByteArray);

%rename("%(camelcase)s", %$isclass) "";
%rename("%(camelcase)s", %$isenum) "";
%rename("%(lowercamelcase)s", %$isfunction) "";
%rename("%(lowercamelcase)s", %$isvariable) "";
%rename("%(strip:[whisper]s", %$isfunction) "";

%include "whisper.h"