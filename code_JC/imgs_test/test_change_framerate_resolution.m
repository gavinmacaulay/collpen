% Script for testing video resize and frame rate change

in_video = '/Volumes/Datos/RedSlip/Oxygen depletion experiment/2015-18-06/40%/11_15/GOPR0006.MP4';
out_video = '/Volumes/Datos/RedSlip/Oxygen depletion experiment/2015-18-06/40%/11_15/GOPR0006_resized_fr.MP4';
target_h = 540;
target_w = 750;
fr = 8;

change_video_framerate_resolution(in_video, out_video, fr, target_h, target_w, 100, 400);