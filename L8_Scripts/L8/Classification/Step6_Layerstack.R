# TODO: Add comment
# 
# Author: cade
###############################################################################



l8.class.dir = "E:\\cade\\SPOT5Take5_11_25_2016\\L8_Classification\\L8_class50"
l8.list <- list.files(path = l8.class.dir, pattern =".tif$", full.names = T)

l8.stack <- stack(l8.list)

write(l8.stack,"E:\\cade\\SPOT5Take5_11_25_2016\\L8_Classification\\L8_class50\\L8_class50_stack.tif")

l8.list2 <- list.files(path = l8.class.dir, pattern =".tif$", full.names = T)
l8.class.stack <- raster(l8.list2[8])