#!/bin/bash

# Check for one argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 input_file.tsv" >&2
    exit 1
fi

input_file="$1"

# Process data and calculate correlations
processed_data=$(awk -F"\t" '
function calc_corr(n, xy, sumx, sumx2, sumy, sumy2) {
    # Calculate denominator
    denom = sqrt((n * sumx2 - sumx * sumx) * (n * sumy2 - sumy * sumy));
    # Return correlation coefficient if denominator is not zero
    return denom ? (n * xy - sumx * sumy) / denom : 0;
}

function abs(x) {
    return x < 0 ? -x : x;
}

{
    if ($8 > 0) {
        count[$1]++;

        pop_xy[$1] += $5 * $8;
        pop_sumx[$1] += $5;
        pop_sumx2[$1] += $5 * $5;

        hom_xy[$1] += $6 * $8;
        hom_sumx[$1] += $6;
        hom_sumx2[$1] += $6 * $6;

        cantril_sum2[$1] += $8 * $8;
        cantril_sum[$1] += $8;

        life_xy[$1] += $7 * $8;
        life_sumx[$1] += $7;
        life_sumx2[$1] += $7 * $7;

        gdp_xy[$1] += $4 * $8;
        gdp_sumx[$1] += $4;
        gdp_sumx2[$1] += $4 * $4;
    }
}
END {
    for (i in count) {
        if (count[i] > 3) {
            pop_corr[i] = calc_corr(count[i], pop_xy[i], pop_sumx[i], pop_sumx2[i], cantril_sum[i], cantril_sum2[i]);
            hom_corr[i] = calc_corr(count[i], hom_xy[i], hom_sumx[i], hom_sumx2[i], cantril_sum[i], cantril_sum2[i]);
            life_corr[i] = calc_corr(count[i], life_xy[i], life_sumx[i], life_sumx2[i], cantril_sum[i], cantril_sum2[i]);
            gdp_corr[i] = calc_corr(count[i], gdp_xy[i], gdp_sumx[i], gdp_sumx2[i], cantril_sum[i], cantril_sum2[i]);

            hom_corr_avg += hom_corr[i];
            life_corr_avg += life_corr[i];
            gdp_corr_avg += gdp_corr[i];
            pop_corr_avg += pop_corr[i];
            count_avg++;
        }
    }

    hom_corr_avg /= count_avg;
    life_corr_avg /= count_avg;
    gdp_corr_avg /= count_avg;
    pop_corr_avg /= count_avg;

    max_corr = hom_corr_avg;
    max_name = "Homicide Rate";

    if (abs(life_corr_avg) > abs(max_corr)) {
        max_corr = life_corr_avg;
        max_name = "Life Expectancy";
    }
    if (abs(gdp_corr_avg) > abs(max_corr)) {
        max_corr = gdp_corr_avg;
        max_name = "GDP";
    }
    if (abs(pop_corr_avg) > abs(max_corr)) {
        max_corr = pop_corr_avg;
        max_name = "Population";
    }

    printf "Mean correlation of Homicide Rate with Cantril ladder is %.3f\n", hom_corr_avg;
    printf "Mean correlation of GDP with Cantril ladder is %.3f\n", gdp_corr_avg;
    printf "Mean correlation of Population with Cantril ladder is %.3f\n", pop_corr_avg;
    printf "Mean correlation of Life Expectancy with Cantril ladder is %.3f\n", life_corr_avg;
    printf "Most predictive mean correlation with the Cantril ladder is %s (r = %.3f)\n", max_name, max_corr;
}' "$input_file")

# Print the result
echo "$processed_data"

