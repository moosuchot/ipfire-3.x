/*
 * str.c - String helper functions that don't need string.h or ctype.h
 *
 * Copyright 2006 Red Hat, Inc.
 *
 * David Cantrell <dcantrell@redhat.com>
 *
 * This software may be freely redistributed under the terms of the GNU
 * general public license.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#include <stdio.h>
#include <stdlib.h>

#include "str.h"

/**
 * Called by str2upper() or str2lower() to do the actual work.
 *
 * @param str String to convert.
 * @param lower Lower bound for the character range (e.g., a - z).
 * @param upper Upper bound for the character range (e.g., a - z).
 * @param shift Shift value (32 for lowercase, -32 for uppercase).
 * @return Pointer to str.
 */
char *str2case(char *str, char lower, char upper, int shift) {
    char *tmp;

    if (str == NULL)
        return NULL;

    /* man ascii(7) */
    tmp = str;
    while (*tmp != '\0') {
        if (*tmp >= lower && *tmp <= upper)
            *tmp += shift;

        tmp++;
    }

    return str;
}

/**
 * Convert given string to uppercase. Modifies the argument in the caller's
 * stack. If you must ask simply "why?" for this function, it's so we don't
 * need toupper() and the same for loop all over the place.
 *
 * LIMITATIONS: Only deals with ASCII character set.
 *
 * @param str String to convert to uppercase.
 * @return Pointer to str.
 */
char *str2upper(char *str) {
    return str2case(str, 'a', 'z', -32);
}

/**
 * Convert given string to lowercase. Modifies the argument in the caller's
 * stack. If you must ask simply "why?" for this function, it's so we don't
 * need tolower() and the same for loop all over the place.
 *
 * LIMITATIONS: Only deals with ASCII character set.
 *
 * @param str String to convert to lowercase.
 * @return Pointer to str.
 */
char *str2lower(char *str) {
    return str2case(str, 'A', 'Z', 32);
}

/**
 * Pretty much an exact copy of index(3) from the C library.
 * @param str String to scan.
 * @param ch Character to scan for.
 * @return Position of ch in str, NULL if not found.
 */
char *strindex(char *str, int ch) {
    if (str == NULL)
        return NULL;

    do {
        if (*str == ch)
            return str;
        else
            str++;
    } while (*str != '\0');

    return NULL;
}

/**
 * Return number of occurrences of a character in a string.
 * @param str String to scan.
 * @param ch Character to scan for.
 * @return Number of occurrences of ch in str.
 */
int strcount(char *str, int ch) {
    int retval = 0;
    char *tmp = str;

    if (tmp == NULL)
        return retval;

    do {
        if ((tmp = strindex(tmp, ch)) != NULL) {
            tmp++;
            retval++;
        }
    } while (tmp != NULL);

    return retval;
}

/* vim:set shiftwidth=4 softtabstop=4: */
