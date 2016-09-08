function beams = get_aris_beam_from_angle(angles)
beams = zeros(1,length(angles));
aris_distortion_pattern =  [[0, -13.661, -13.762, -13.553];
    [1, -13.445, -13.553, -13.337];
    [2, -13.229, -13.337, -13.112];
    [3, -12.995, -13.112, -12.878];
    [4, -12.761, -12.878, -12.644];
    [5, -12.527, -12.644, -12.410];
    [6, -12.293, -12.410, -12.176];
    [7, -12.058, -12.176, -11.932];
    [8, -11.806, -11.932, -11.680];
    [9, -11.554, -11.680, -11.428];
    [10, -11.302, -11.428, -11.176];
    [11, -11.050, -11.176, -10.924];
    [12, -10.798, -10.924, -10.672];
    [13, -10.545, -10.672, -10.419];
    [14, -10.293, -10.419, -10.167];
    [15, -10.041, -10.167, -9.906];
    [16, -9.771, -9.906, -9.636];
    [17, -9.501, -9.636, -9.366];
    [18, -9.231, -9.366, -9.096];
    [19, -8.960, -9.096, -8.825];
    [20, -8.690, -8.825, -8.546];
    [21, -8.402, -8.546, -8.258];
    [22, -8.114, -8.258, -7.970];
    [23, -7.826, -7.970, -7.682];
    [24, -7.538, -7.682, -7.393];
    [25, -7.249, -7.393, -7.105];
    [26, -6.961, -7.105, -6.808];
    [27, -6.655, -6.808, -6.502];
    [28, -6.349, -6.502, -6.196];
    [29, -6.043, -6.196, -5.890];
    [30, -5.736, -5.890, -5.583];
    [31, -5.430, -5.583, -5.277];
    [32, -5.124, -5.277, -4.971];
    [33, -4.818, -4.971, -4.656];
    [34, -4.494, -4.656, -4.332];
    [35, -4.169, -4.332, -4.007];
    [36, -3.845, -4.007, -3.683];
    [37, -3.521, -3.683, -3.359];
    [38, -3.197, -3.359, -3.035];
    [39, -2.873, -3.035, -2.710];
    [40, -2.548, -2.710, -2.386];
    [41, -2.224, -2.386, -2.053];
    [42, -1.882, -2.053, -1.711];
    [43, -1.540, -1.711, -1.369];
    [44, -1.198, -1.369, -1.026];
    [45, -0.855, -1.026, -0.684];
    [46, -0.513, -0.684, -0.342];
    [47, -0.171, -0.342, 0.000];
    [48, 0.171, 0.000, 0.342];
    [49, 0.513, 0.342, 0.684];
    [50, 0.855, 0.684, 1.026];
    [51, 1.198, 1.026, 1.369];
    [52, 1.540, 1.369, 1.711];
    [53, 1.882, 1.711, 2.053];
    [54, 2.224, 2.053, 2.386];
    [55, 2.548, 2.386, 2.710];
    [56, 2.873, 2.710, 3.035];
    [57, 3.197, 3.035, 3.359];
    [58, 3.521, 3.359, 3.683];
    [59, 3.845, 3.683, 4.007];
    [60, 4.169, 4.007, 4.332];
    [61, 4.494, 4.332, 4.656];
    [62, 4.818, 4.656, 4.971];
    [63, 5.124, 4.971, 5.277];
    [64, 5.430, 5.277, 5.583];
    [65, 5.736, 5.583, 5.890];
    [66, 6.043, 5.890, 6.196];
    [67, 6.349, 6.196, 6.502];
    [68, 6.655, 6.502, 6.808];
    [69, 6.961, 6.808, 7.105];
    [70, 7.249, 7.105, 7.393];
    [71, 7.538, 7.393, 7.682];
    [72, 7.826, 7.682, 7.970];
    [73, 8.114, 7.970, 8.258];
    [74, 8.402, 8.258, 8.546];
    [75, 8.690, 8.546, 8.825];
    [76, 8.960, 8.825, 9.096];
    [77, 9.231, 9.096, 9.366];
    [78, 9.501, 9.366, 9.636];
    [79, 9.771, 9.636, 9.906];
    [80, 10.041, 9.906, 10.167];
    [81, 10.293, 10.167, 10.419];
    [82, 10.545, 10.419, 10.672];
    [83, 10.798, 10.672, 10.924];
    [84, 11.050, 10.924, 11.176];
    [85, 11.302, 11.176, 11.428];
    [86, 11.554, 11.428, 11.680];
    [87, 11.806, 11.680, 11.932];
    [88, 12.058, 11.932, 12.176];
    [89, 12.293, 12.176, 12.410];
    [90, 12.527, 12.410, 12.644];
    [91, 12.761, 12.644, 12.878];
    [92, 12.995, 12.878, 13.112];
    [93, 13.229, 13.112, 13.337];
    [94, 13.445, 13.337, 13.553];
    [95, 13.661, 13.553, 13.762]];

for j = 1:length(beams)
    for i = 1:length(aris_distortion_pattern)
        if angles(j) < aris_distortion_pattern(i,4)
            beams(j) = i;
            break;
        end
    end
end
end