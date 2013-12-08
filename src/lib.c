#include "picrin.h"
#include "picrin/lib.h"
#include "picrin/pair.h"
#include "picrin/macro.h"
#include "xhash/xhash.h"

struct pic_lib *
pic_make_library(pic_state *pic, pic_value name)
{
  struct pic_lib *lib;

  lib = (struct pic_lib *)pic_obj_alloc(pic, sizeof(struct pic_lib), PIC_TT_LIB);
  lib->senv = pic_minimal_syntactic_env(pic);
  lib->exports = xh_new();
  lib->name = name;

  /* register! */
  pic->lib_tbl = pic_acons(pic, name, pic_obj_value(lib), pic->lib_tbl);

  return lib;
}

void
pic_in_library(pic_state *pic, pic_value name)
{
  pic_value v;

  v = pic_assoc(pic, name, pic->lib_tbl);
  if (pic_false_p(v)) {
    pic_error(pic, "library not found");
  }
  pic->lib = pic_lib_ptr(pic_cdr(pic, v));
}

struct pic_lib *
pic_find_library(pic_state *pic, pic_value spec)
{
  pic_value v;

  v = pic_assoc(pic, spec, pic->lib_tbl);
  if (pic_false_p(v)) {
    return NULL;
  }
  return pic_lib_ptr(pic_cdr(pic, v));
}