#include <argp.h>
#include <stdlib.h>

const char *argp_program_version = "God 0.1.0";
const char *argp_program_bug_address =
    "https://github.com/haruki7049/God/issues";

static char doc[] = "God -- A joke command, with Git command help";

static struct argp argp = {0, 0, 0, doc};

int main(int argc, char **argv) {
  argp_parse(&argp, argc, argv, 0, 0, 0);
  exit(0);
}
