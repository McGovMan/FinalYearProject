#include <stdbool.h>
#include <stdio.h>

#include <xtables.h>
#include "ipt_redirect.h"

static void redirect_help(void)
{
    printf(
            "REDIRECT target options:\n"
            "  none\n");
}

static const struct xt_option_entry redirect_opts[] = {
        XTOPT_TABLEEND,
};

static void redirect_parse(struct xt_option_call *cb)
{
    xtables_option_parse(cb);
}

static void redirect_check(struct xt_fcheck_call *cb)
{
}

static void redirect_print(const void *ip, const struct xt_entry_target *target,
                              int numeric)
{
    const struct ipt_proxyalt_info *info =
            (const struct ipt_proxyalt_info *)target->data;

    printf(" REDIRECT ");
}

static void redirect_save(const void *ip, const struct xt_entry_target *target)
{

}

static struct xtables_target redirect_reg = {
        .family        = NFPROTO_UNSPEC,
        .name          = "REDIRECT",
        .version       = XTABLES_VERSION,
        .revision      = 0,
        .size          = XT_ALIGN(sizeof(struct ipt_redirect_info)),
        .userspacesize = XT_ALIGN(sizeof(struct ipt_redirect_info)),
        .help          = redirect_help,
        .print         = redirect_print,
        .save          = redirect_save,
        .x6_parse      = redirect_parse,
        .x6_fcheck     = redirect_check,
        .x6_options    = redirect_opts,
};

void _init(void)
{
    xtables_register_target(&redirect_reg);
}
