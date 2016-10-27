# DataSampler 2D

## Beacons tab
for sampling

### Sampling origin
* origin of sampling (x, y, floor)
* if you want to build a huge 2D space, you may want to divide the area into some sub areas. Server app is required for setting.
* default origins are provided

### Coordination
* x and y is obvious
* z can be used to define the height on floor (ex. steps) but usually 0.

### Sampling
* "+"/"-" to incrase/decrease number of samples (timer) at a location
* "Start" to start sampling
* "Stop" to stop sampling with saving data
* "Cancel" to stop sampling without saving data
* You can see how many beacons are observed when you start sampling

## Settings tab

### Server Host
* set your server address
* server provides origin settings
* server can store sampling data and visualize

### Beacon UUID

### Site ID
* Any string, to identify data


## Sampling Method
* Set sampling origin in your environment
* Mark grid point (1-5m grid based on required accuracy)
 * must be right-hand system (x-right, y-front, z-above)
* Move to a point
* Change x, y setting
* Start sampling and rotate at the point (1-2 around in 30 seconds)
 * for better accuracy for walking from every direction

----
## About
[About HULOP](https://github.com/hulop/00Readme)


## License
[MIT](http://opensource.org/licenses/MIT)

## README
This Human Scale Localization Platform library is intended solely for use with an Apple iOS product and intended to be used in conjunction with officially licensed Apple development tools and further customized and distributed under the terms and conditions of your licensed Apple developer program.
