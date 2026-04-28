# print() vs cat():
# print() is a generic function that displays the object with its metadata (e.g., [1] for vectors).
# cat() (concatenate and print) prints the raw content directly to the console without indices,
# making it better for formatted text and logging.

print("Hello, World from biomod++! using print()")
print(paste("R version:", R.version.string))

cat("Hello, World from biomod++! using cat()\n")
cat("R version:", R.version.string, "\n")
