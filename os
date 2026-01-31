#include <stdio.h>
#include <time.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
int main() {
// 1. Print current system time
time_t now;
time(&now);
printf("Current System Time: %s", ctime(&now));

// 2. Do some dummy computation
long long sum = 0;
for (long long i = 0; i < 500000000; i++) {
sum += i;
}
printf("Dummy computation result: %lld\n", sum);

// 3. Read /proc/self/stat to get CPU times
FILE *fp = fopen("/proc/self/stat", "r");
if (fp == NULL) {
perror("Error opening /proc/self/stat");
return 1;
}
/*
/proc/self/stat has many fields.
We need:
Field 14 = utime (user mode ticks)
Field 15 = stime (kernel mode ticks)
*/
int i;
char buffer[4096];
long utime_ticks, stime_ticks;
// Read entire line
fgets(buffer, sizeof(buffer), fp);
fclose(fp);
// Tokenize
char *token = strtok(buffer, " ");
for (i = 1; i <= 15; i++) {
if (i == 14) utime_ticks = atol(token);
if (i == 15) stime_ticks = atol(token);
token = strtok(NULL, " ");
}
// Get system clock ticks per second
long ticks_per_sec = sysconf(_SC_CLK_TCK);
double user_time_sec = (double) utime_ticks / ticks_per_sec;
double kernel_time_sec = (double) stime_ticks / ticks_per_sec;
// Print results
printf("\n=== Process CPU Usage ===\n");
printf("User mode time : %.6f seconds\n", user_time_sec);
printf("Kernel mode time : %.6f seconds\n", kernel_time_sec);
return 0;
}
