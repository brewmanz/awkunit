#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <assert.h>
#include <unistd.h>

#include <sys/types.h>
#include <sys/stat.h>

#include "gawkapi.h"
#include "gettext.h"
#define _(msgid) gettext(msgid)
#define N_(msgid) msgid

#include "gawkfts.h"
#include "stack.h"

#define BUFFER_SIZE 256

int plugin_is_GPL_compatible;

static const gawk_api_t *api; // boilerplate code is wrong!
static awk_ext_id_t ext_id;
static const char *ext_version = "AwkUnit: version 0.5.1";

awk_bool_t init_my_extension(void){
  fprintf(stderr, "(%s; do_debug=%s)\n", "awkunit being loaded", (do_debug ? "T" : "F"));
  return awk_true;
}
static awk_bool_t (*init_func)(void) = init_my_extension;

#define DO_GETDEBUGFLAG_MAX_ARGS 0
#define DO_GETDEBUGFLAG_MIN_ARGS 0
static awk_value_t *do_getDebugFlag(int nargs, awk_value_t *result, awk_ext_func_t *ext_func)
{
     return make_number(do_debug, result);
}

#define DO_PROCESSIOTOARRAY_MAX_ARGS 4
#define DO_PROCESSIOTOARRAY_MIN_ARGS 3
static awk_value_t *do_processIoToArray(int nArgs, awk_value_t *result, awk_ext_func_t *ext_func)
{
    awk_value_t scriptFileName, inFileName, outArray, runOptions;
    int ret = -1;
    FILE *fpipe;
    char *command = NULL, pbuf[BUFFER_SIZE];

    assert(result != NULL);

    if (do_lint && (nArgs < DO_PROCESSIOTOARRAY_MIN_ARGS || nArgs > DO_PROCESSIOTOARRAY_MAX_ARGS))
      lintwarn(ext_id,
        _("awkunit::processIoToArray: called with incorrect number of arguments, expecting 3 or 4"));

    if (get_argument(0, AWK_STRING, &scriptFileName)
      && get_argument(1, AWK_STRING, &inFileName)
      && get_argument(2, AWK_ARRAY, &outArray)) {
      ret = 0;
    } else {
      fprintf(stderr, "Error: do_processIoToArray(): incorrect number or type of arguments; %d passed\n", nArgs);
      exit(-1);
    }

    if(nArgs > 3){
      if (get_argument(3, AWK_STRING, &runOptions)) {
        ret = 0;
      } else {
        fprintf(stderr, "Error: do_processIoToArray(): argument 4 (runOptions) not a string(%d) but %d\n", AWK_STRING, runOptions.val_type);
        exit(-1);
      }
    } else {
      make_const_string("", 0, &runOptions);
    }
//printf("do_processIoToArray: outArray.val_type=%d(AWK_ARRAY=%d).\n", outArray.val_type, AWK_ARRAY);

    int cmdLen = scriptFileName.str_value.len + inFileName.str_value.len + runOptions.str_value.len + 16;
    command = (char *)malloc(cmdLen);
    strncpy(command, "gawk ", cmdLen); // 5 + 1
    if(do_debug){
      strncat(command, "-D ", cmdLen); // +3
    }
    strncat(command, runOptions.str_value.str, cmdLen);
    strncat(command, " -f ", cmdLen); // +4
    strncat(command, scriptFileName.str_value.str, cmdLen);
    strncat(command, " < ", cmdLen); // +3
    strncat(command, inFileName.str_value.str, cmdLen);
    if(do_debug){
      printf("do_processIoToArray: command=`%s`\n", command);
    }

    if (!(fpipe = (FILE *)popen(command, "r"))) {
      perror("Fatal error: cannot open pipe");
      exit(-1);
    }

    // prepare returning array
    awk_array_t theArray;
    theArray = create_array();
    if(outArray.val_type != AWK_ARRAY){
      // never called - so far. SO ALWAYS print
      if (set_argument(2, theArray)) {
        printf("do_processIoToArray: set_argument(2) to array OK\n");
      } else {
        printf("do_processIoToArray: set_argument(2) to array FAILED.\n");
        //printf("do_processIoToArray: set_argument(2) to array FAILED. ERRNO=%s.\n", *errcode);
        //exit(-1);
        return make_number(ret, result);
      }
      outArray.val_type = AWK_ARRAY;
      outArray.array_cookie = theArray;
      //sym_update(outArray.)
    }
    theArray = outArray.array_cookie; // YOU MUST DO THIS
    awk_value_t theKey, theValue;
    //outArray.

    // loop for each output line
    int nr = 0;
    while (fgets(pbuf, BUFFER_SIZE, fpipe)) {
      ++nr;
      // get line
      int pLen = strnlen(pbuf, BUFFER_SIZE); if(pLen > 0) { pbuf[pLen-1] = '\0'; --pLen; } // trim trailing \n
      make_const_string(pbuf, pLen, &theValue);

      // add to array, using line number 1..N as key
      make_number(nr, &theKey);
      if (set_array_element(theArray, & theKey, & theValue)) {
        if(do_debug){
          printf("do_processIoToArray: setting[%d] to <%s>\n", nr, pbuf);
        }
      } else {
        printf("do_processIoToArray: set_array_element failed.\n");
        //printf("do_processIoToArray: set_array_element failed. ERRNO=%s.\n", *errcode);
        return make_number(ret, result);
      }
     }

     pclose(fpipe);
     return make_number(ret, result);
}

#define DO_ASSERTIO_MAX_ARGS 3
#define DO_ASSERTIO_MIN_ARGS 3
static awk_value_t *do_assertIO(int nargs, awk_value_t *result, awk_ext_func_t *ext_func)
{
     awk_value_t scriptFile, inFile, outFile;
     int ret = -1;
     FILE *fpipe, *fo, *fi;
     char *command = NULL, pbuf[BUFFER_SIZE], obuf[BUFFER_SIZE], ibuf[BUFFER_SIZE];

     assert(result != NULL);

     if (do_lint && nargs != 3)
          lintwarn(ext_id,
                   _("awkunit::assertIO: called with incorrect number of arguments, "
                     "expecting 3"));

     if (get_argument(0, AWK_STRING, &scriptFile) &&
         get_argument(1, AWK_STRING, &inFile) &&
         get_argument(2, AWK_STRING, &outFile)) {
          ret = 0;
     } else {
          fprintf(stderr, "Error: do_assertIO(): incorrect number or type of arguments; %d passed\n", nargs);
          exit(-1);
     }

     // prepare command
     command = (char *)malloc(scriptFile.str_value.len +
                              inFile.str_value.len + 15);
     strcpy(command, "gawk ");
     if(do_debug){
      strcat(command, "-D ");
     }
     strcat(command, "-f ");
     strcat(command, scriptFile.str_value.str);
     strcat(command, " < ");
     strcat(command, inFile.str_value.str);

     if (!(fpipe = (FILE *)popen(command, "r"))) {
          perror("Fatal error: cannot open pipe");
          exit(-1);
     }
     if (!(fo = fopen(outFile.str_value.str, "r"))) {
          perror("Fatal error: cannot open file");
          exit(-1);
     }
     if (!(fi = fopen(inFile.str_value.str, "r"))) {
          perror("Fatal error: cannot input file");
          exit(-1);
     }

     int nr = 0;
     while (fgets(pbuf, BUFFER_SIZE, fpipe)) {
          ++nr;
          fgets(obuf, BUFFER_SIZE, fo);
          fgets(ibuf, BUFFER_SIZE, fi);
          if (strcmp(pbuf, obuf) != 0) {
              int pLen = strnlen(pbuf, BUFFER_SIZE); if(pLen > 0) { pbuf[pLen-1] = '\0'; } // trim trailing \n
              int oLen = strnlen(obuf, BUFFER_SIZE); if(oLen > 0) { obuf[oLen-1] = '\0'; } // trim trailing \n
              int iLen = strnlen(ibuf, BUFFER_SIZE); if(iLen > 0) { ibuf[iLen-1] = '\0'; } // trim trailing \n
               fprintf(stderr, "Assertion failed: %s: output differs from file (%s)\n",
                       inFile.str_value.str, outFile.str_value.str);
               fprintf(stderr, "pL=%d, oL=%d, iL=%d\n",
                       pLen, oLen, iLen);
               fprintf(stderr, "NR=%d: input <%s> made output \n<%s> which differs from expected \n<%s>\n",
                       nr, ibuf, pbuf, obuf);
               sym_update("_assert_exit", make_number(-1, result));
               pclose(fpipe);
               fclose(fo);
               fclose(fi);
               exit(-1);
          }
     }

     pclose(fpipe);
     fclose(fo);
     fclose(fi);
     return make_number(ret, result);
}

static awk_ext_func_t func_table[] = {
     {"getDebugFlag", do_getDebugFlag, DO_GETDEBUGFLAG_MAX_ARGS, DO_GETDEBUGFLAG_MIN_ARGS},
     {"processIoToArray", do_processIoToArray, DO_PROCESSIOTOARRAY_MAX_ARGS, DO_PROCESSIOTOARRAY_MIN_ARGS},
     {"assertIO", do_assertIO, DO_ASSERTIO_MAX_ARGS, DO_ASSERTIO_MIN_ARGS},
};

dl_load_func(func_table, some_name, "awkunit")
