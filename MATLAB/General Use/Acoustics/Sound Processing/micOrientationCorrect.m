function CA = micOrientationCorrect(F, th, A)
%This program corrects spectra for microphone orientation based on the
%value given in the vector "th" in degrees. Normal microphone incidence is
%indicated by th==0.

%Correction is based on the difference in dB between the response at 0
%angle incidence as compared to one of several reference angles(0, 30, 60, 90).

[FFR_th,FFR_Freq,FFResponse] = getFFR;   %Gets free-field information stored at end of file.  

if max(th)>90 || min(th)<0
    disp('Error: Angle(s) out of bounds (0 to 90 degs)')
elseif max(F)>149624 || min(F)<1
    disp('Error: Frequencies out of bounds (1 to 149624 Hz)')
else
    [X,Y]=size(F);
    if X>Y%determines orientation of Frequency array (Nx1 or 1xN)
        FFRD = interp2(FFR_th,FFR_Freq,FFResponse,th,F);%Calculates the free-field response for the data
    else
        FFRD = interp2(FFR_th,FFR_Freq, FFResponse, th, F');
    end
    CA = A - FFRD;%corrects amplitude based on free-field response
end
return


function [FFR_th,FFR_Freq,FFResponse] = getFFR();

FFR_th=[0 30 60 90];  %The angles for which the free-field response was measured.

    %Matrix contains the free-field response as a function of frequency for
    %the above angles.
FFResponse=[
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0	0	0
0	0.008	0.006	0.015
0	0.008	0.006	0.014
0	0.007	0.005	0.013
0	0.007	0.005	0.012
0	0.007	0.004	0.011
0	0.006	0.004	0.01
0	0.006	0.004	0.009
0	0.006	0.003	0.008
0	0.004	0.002	0.005
0	0.004	0.001	0.004
0	0.004	0.001	0.003
0	0.003	0	0.001
0	0.002	-0.001	-0.001
0	0.002	-0.001	-0.002
0	0.001	-0.003	-0.004
0	0	-0.004	-0.007
0	0	-0.005	-0.009
0	-0.001	-0.006	-0.011
0	-0.001	-0.007	-0.014
0	-0.003	-0.009	-0.017
0	-0.003	-0.01	-0.019
0	-0.004	-0.012	-0.023
0	-0.006	-0.014	-0.027
0	-0.007	-0.016	-0.03
0	-0.007	-0.018	-0.034
0	-0.008	-0.019	-0.038
0	-0.01	-0.022	-0.043
0	-0.011	-0.025	-0.048
0	-0.012	-0.028	-0.053
0	-0.013	-0.031	-0.058
0	-0.014	-0.033	-0.063
0	-0.016	-0.037	-0.07
0	-0.017	-0.041	-0.077
0	-0.018	-0.045	-0.084
0	-0.02	-0.05	-0.092
0	-0.021	-0.055	-0.101
0	-0.022	-0.059	-0.109
0	-0.024	-0.065	-0.119
0	-0.026	-0.072	-0.13
0	-0.028	-0.079	-0.142
0	-0.029	-0.086	-0.154
0	-0.031	-0.094	-0.167
0	-0.032	-0.102	-0.181
0	-0.035	-0.112	-0.197
0	-0.036	-0.122	-0.214
0	-0.037	-0.133	-0.231
0	-0.04	-0.145	-0.251
0	-0.042	-0.158	-0.272
0	-0.043	-0.171	-0.294
0	-0.046	-0.187	-0.319
0	-0.048	-0.202	-0.345
0	-0.051	-0.219	-0.373
0	-0.053	-0.238	-0.404
0	-0.057	-0.259	-0.439
0	-0.06	-0.279	-0.473
0	-0.063	-0.3	-0.509
0	-0.068	-0.321	-0.545
0	-0.073	-0.345	-0.588
0	-0.08	-0.37	-0.633
0	-0.089	-0.401	-0.692
0	-0.097	-0.424	-0.737
0	-0.11	-0.453	-0.797
0	-0.123	-0.482	-0.858
0	-0.138	-0.51	-0.919
0	-0.157	-0.545	-0.996
0	-0.177	-0.58	-1.075
0	-0.197	-0.616	-1.155
0	-0.217	-0.654	-1.237
0	-0.236	-0.695	-1.321
0	-0.258	-0.748	-1.426
0	-0.276	-0.806	-1.532
0	-0.292	-0.873	-1.645
0	-0.304	-0.958	-1.78
0	-0.312	-1.055	-1.922
0	-0.318	-1.175	-2.092
0	-0.329	-1.336	-2.313
0	-0.348	-1.503	-2.542
0	-0.385	-1.672	-2.782
0	-0.446	-1.835	-3.027
0	-0.532	-1.99	-3.279
0	-0.635	-2.138	-3.539
0	-0.763	-2.304	-3.86
0	-0.873	-2.458	-4.188
0	-0.943	-2.603	-4.526
0	-0.955	-2.758	-4.924
0	-0.908	-2.919	-5.351
0	-0.845	-3.081	-5.747
0	-0.809	-3.32	-6.211
0	-0.854	-3.52	-6.497
0	-0.96	-3.783	-6.849
0	-1.05	-4.013	-7.259
0	-1.071	-4.186	-7.773
0	-1.07	-4.41	-8.496
0	-1.168	-4.754	-9.132
0	-1.364	-5.231	-9.598
0	-1.575	-5.638	-10.111
0	-1.745	-5.848	-10.604
0	-1.822	-6.077	-11.226
0	-1.873	-6.409	-11.792
0	-1.884	-6.801	-12.522
0	-1.925	-7.058	-12.981
0	-1.996	-7.388	-13.537
0	-2.169	-8.005	-14.111
0	-2.366	-8.468	-15.506
0	-2.841	-9.702	-17.131
0	-3.247	-10.574	-17.888
0	-3.212	-10.175	-16.762
0	-2.448	-9.196	-16.131
0	-1.693	-8.559	-15.799
0	-1.555	-8.915	-17.529
0	-2.147	-10.274	-20.221
0	-2.736	-11.746	-22.901
0	-3.465	-13.819	-27.18
0	-4.647	-16.647	-29.912
0	-5.732	-19.343	-28.399
0	-6.793	-19.689	-28.399];%No data was provided for Frequency=149624, th=90

FFR_Freq=[
1
1.05925
1.12202
1.1885
1.25893
1.33352
1.41254
1.49624
1.58489
1.6788
1.77828
1.88365
1.99526
2.11349
2.23872
2.37137
2.51189
2.66073
2.81838
2.98538
3.16228
3.34965
3.54813
3.75837
3.98107
4.21696
4.46684
4.73151
5.01187
5.30884
5.62341
5.95662
6.30957
6.68344
7.07946
7.49894
7.94328
8.41395
8.91251
9.44061
10
10.5925
11.2202
11.885
12.5893
13.3352
14.1254
14.9624
15.8489
16.788
17.7828
18.8365
19.9526
21.1349
22.3872
23.7137
25.1189
26.6073
28.1838
29.8538
31.6228
33.4965
35.4813
37.5837
39.8107
42.1697
44.6684
47.3151
50.1187
53.0885
56.2341
59.5662
63.0957
66.8344
70.7946
74.9894
79.4328
84.1395
89.1251
94.4061
100
105.925
112.202
118.85
125.893
133.352
141.254
149.624
158.489
167.88
177.828
188.365
199.526
211.349
223.872
237.137
251.189
266.073
281.838
298.538
316.228
334.965
354.813
375.837
398.107
421.697
446.684
473.151
501.187
530.884
562.341
595.662
630.957
668.344
707.946
749.894
794.328
841.395
891.251
944.061
1000
1059.25
1122.02
1188.5
1258.93
1333.52
1412.54
1496.24
1584.89
1678.8
1778.28
1883.65
1995.26
2113.49
2238.72
2371.37
2511.89
2660.73
2818.38
2985.38
3162.28
3349.65
3548.13
3758.37
3981.07
4216.97
4466.84
4731.51
5011.87
5308.84
5623.41
5956.62
6309.57
6683.44
7079.46
7498.94
7943.28
8413.95
8912.51
9440.61
10000
10592.5
11220.2
11885
12589.3
13335.2
14125.4
14962.4
15848.9
16788
17782.8
18836.5
19952.6
21134.9
22387.2
23713.7
25118.9
26607.3
28183.8
29853.8
31622.8
33496.5
35481.3
37583.7
39810.7
42169.7
44668.4
47315.1
50118.7
53088.4
56234.1
59566.2
63095.7
66834.4
70794.6
74989.4
79432.8
84139.5
89125.1
94406.1
100000
105925
112202
118850
125893
133352
141254
149624];