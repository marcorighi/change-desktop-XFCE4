# change-desktop-XFCE4

### Description

This bash script is designed to automatically change the desktop background images on multiple monitors for an XFCE desktop environment. The script uses a configuration file to manage the directories of images for each monitor and employs counters to cycle through the images. The counters are stored in a file and updated periodically to ensure the script resumes from where it left off even after a restart. The script allows specifying a sleep time interval to control how often the background images are changed.

### Features

1. **Configuration Management**:
   - The script requires a configuration file as an input parameter, which defines directories containing images for each monitor.
   - It verifies the existence of the configuration file before proceeding.

2. **Counter Management**:
   - Counters for each monitor are read from a file and are used to track the current image.
   - If the counter file does not exist, counters are initialized to zero.
   - After each image change, counters are incremented and saved back to the file.

3. **Image Cycling**:
   - The script cycles through images in the specified directories for each monitor.
   - It ensures the counters loop back to zero after reaching the maximum number of images.

4. **Logging**:
   - Logging of key events and state changes is performed to a log file, providing transparency and debugging support.

5. **Background Image Setting**:
   - Uses `xfconf-query` to set the background images for XFCE desktop environment.
   - Sets the style of the background image to "Scaled."

6. **Sleep Interval**:
   - The sleep interval between changing images is configurable through a parameter, allowing flexibility in how frequently the backgrounds are updated.

### Usage

```bash
./change_wallpapers.sh configfile sleeptime
```

- `configfile`: Path to the configuration file containing directories of images for each monitor.
- `sleeptime`: Time in seconds to wait before changing the background images again.

### Example Configuration File

The configuration file should set environment variables pointing to the directories containing the images:

```bash
MONITOR1_DIR="/path/to/monitor1/images"
MONITOR2_DIR="/path/to/monitor2/images"
MONITOR3_DIR="/path/to/monitor3/images"
MONITOR1="monitor1"
MONITOR2="monitor2"
MONITOR3="monitor3"
```

### Dependencies

- `bash`
- `xfconf-query` (part of XFCE desktop environment)

### Script Details

- **Reading and Saving Counters**: Functions `read_counters` and `save_counters` manage the state of image counters.
- **Incrementing Counters**: Function `increment_counter` ensures counters loop correctly.
- **Changing Wallpapers**: Function `change_wallpapers` updates the background images and logs the changes.
- **Main Loop**: The script runs in an infinite loop, changing wallpapers and then sleeping for the specified time interval.

This script provides a robust solution for dynamically managing multiple desktop backgrounds in an XFCE environment, making it ideal for users who enjoy regularly changing their desktop aesthetics.

