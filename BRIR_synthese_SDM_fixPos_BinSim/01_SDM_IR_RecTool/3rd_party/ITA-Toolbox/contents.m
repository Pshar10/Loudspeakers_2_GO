% RWTH - ITA Toolbox
% Version 2.0 (BSD License Ready) 1-Jun-2011
% Files
% 
% ITA-Toolbox/Debug
% 
%   test_ita_Value                          <ITA-Toolbox>
%   test_ita_analysis                       <ITA-Toolbox>
%   test_ita_arithmetic                     <ITA-Toolbox>
%   test_ita_class                          <ITA-Toolbox>
%   test_ita_convolve                       <ITA-Toolbox>
%   test_ita_coordinates                    <ITA-Toolbox>
%   test_ita_edit                           <ITA-Toolbox>
%   test_ita_fileIO                         <ITA-Toolbox>
%   test_ita_filter                         <ITA-Toolbox>
%   test_ita_parametric_GUI                 <ITA-Toolbox>
%   test_ita_parse_arguments                <ITA-Toolbox>
%   test_ita_portaudio                      <ITA-Toolbox>
%   test_ita_rms                            <ITA-Toolbox>
% 
% ITA-Toolbox/ExternalPackages/RegularizationToolbox
% 
%   bidiag                                  Bidiagonalization of an m-times-n matrix with m >= n.
%   corner                                  Find  of discrete L-curve via adaptive pruning algorithm.
%   foxgood                                 Test problem: severely ill-posed problem.
%   gen_form                                Transform a standard-form problem back to the general-form setting.
%   gravity                                 Test problem: 1-D  surveying model problem
%   l_corner                                Locate the "corner" of the L-curve.
%   l_curve                                 Plot the L-curve and find its "corner".
%   mr2                                     Solution of symmetric indefinite problems by the MR-II algorithm
%   nu                                      Brakhage's -method.
%   pinit                                   Utility init.-procedure for "preconditioned" iterative methods.
%   plot_lc                                 Plot the L-curve.
%   pmr2                                    Preconditioned MR-II algorithm for symmetric indefinite problems
%   pnu                                     "Preconditioned" version of Brakhage's nu-method.
%   quasiopt                                Quasi-optimality criterion for choosing the reg. parameter
%   rrgmres                                 Range-restricted GMRES algorithm for square inconsistent systems
%   shaw                                    Test problem: one-dimensional image restoration model.
%   splsqr                                  Subspace preconditioned LSQR for discrete ill-posed problems.
%   splsqrL                                 SPLSQR Subspace preconditioned LSQR for discrete ill-posed problems.
%   std_form                                Transform a general-form reg. problem into one in standard form.
% 
% ITA-Toolbox/ExternalPackages
% 
% 
% ITA-Toolbox/ExternalPackages/dirplot
% 
% 
% ITA-Toolbox/ExternalPackages/dpsimplify
% 
%   dpsimplify                              Recursive Douglas-Peucker Polyline Simplification, Simplify
% 
% ITA-Toolbox/ExternalPackages/effectSizeToolbox
% 
% 
% ITA-Toolbox/ExternalPackages/export_fig
% 
% 
% ITA-Toolbox/ExternalPackages
% 
% 
% ITA-Toolbox/ExternalPackages/rdir
% 
% 
% ITA-Toolbox/ExternalPackages/sofa/API_MO
% 
% 
% ITA-Toolbox/ExternalPackages/sofa/API_MO/converters
% 
% 
% ITA-Toolbox/ExternalPackages/sofa/API_MO/coordinates
% 
% 
% ITA-Toolbox/ExternalPackages/sofa/API_MO/demos
% 
%   demo_CIPIC2SOFA                         Copyright (C) 2012-2013 Acoustics Research InstituteAustrian Academy of Sciences;
% 
% ITA-Toolbox/ExternalPackages/sofa/API_MO/helper
% 
% 
% ITA-Toolbox/ExternalPackages/sofa/API_MO/matlab
% 
% 
% ITA-Toolbox/ExternalPackages/sofa/API_MO/octave
% 
% 
% ITA-Toolbox/ExternalPackages/sofa/API_MO/test
% 
% 
% ITA-Toolbox/ExternalPackages/sofa/itaFunctions
% 
% 
% ITA-Toolbox/ExternalPackages
% 
% 
% ITA-Toolbox/ExternalPackages/uff-stuff
% 
% 
% ITA-Toolbox/ExternalPackages/verbatim
% 
% 
% ITA-Toolbox/ExternalPackages/xml2struct
% 
% 
% ITA-Toolbox/applications/LoudspeakerTools/Menucallbacks
% 
%   ita_menucallback_CombineNearfieldAndFarfieldMeasurements<ITA-Toolbox>
%   ita_menucallback_FreefieldResponse      <ITA-Toolbox>
%   ita_menucallback_THD                    <ITA-Toolbox>
%   ita_menucallback_ThieleSmallParameters  <ITA-Toolbox>
% 
% ITA-Toolbox/applications/LoudspeakerTools
% 
%   ita_add_nearfield_farfield_measurements for loudspeaker near-field measurements
%   ita_loudspeakertools_distortions        Calculate the THD, THD-N and HD's with
%   ita_thiele_small                        Calculation of Thiele-Small Paramters
% 
% ITA-Toolbox/applications/Measurement/ClassStuff
% 
%   ita_device_list_handle                  <ITA-Toolbox>
%   test_ita_MeasurementSetup               <ITA-Toolbox>
% 
% ITA-Toolbox/applications/Measurement/MLS
% 
% 
% ITA-Toolbox/applications/Measurement/MeasurementCallbacks
% 
%   ita_ChooseMeasurement_gui               <ITA-Toolbox>
%   ita_guisupport_measurement_get_global_MS<ITA-Toolbox>
%   ita_menucallback_EditMeasurement        <ITA-Toolbox>
%   ita_menucallback_MeasuringStationPreferences<ITA-Toolbox>
%   ita_menucallback_NewMeasurementSetup    <ITA-Toolbox>
%   ita_menucallback_NewMeasuringStation    <ITA-Toolbox>
%   ita_menucallback_RunMeasurement2File    <ITA-Toolbox>
% 
% ITA-Toolbox/applications/Measurement
% 
% 
% ITA-Toolbox/applications/Nonlinear/guicallbacks
% 
%   ita_menucallback_PolynomialSeries       <ITA-Toolbox>
% 
% ITA-Toolbox/applications/Nonlinear
% 
% 
% ITA-Toolbox/applications/PoleZeroProny
% 
%   ita_AudioAnalyticRationalMatrix2itaAudioMatrix-
%   ita_audio2zpk_rationalfit               ITA_AUDIO2ZPKPole-Zero-Analysis
%   ita_result2audio_pdi                    Pole-Zero Interpolation Method
%   pdi_prony                               Prony's method for time-domain IIR filter design (memory fix!).
% 
% ITA-Toolbox/applications/RoomAcoustics
% 
%   ita_preferences_roomacoustics           <ITA-Toolbox>
%   ita_roomacoustics_EDC                   calculate reverse-time integrated impulse response
% 
% ITA-Toolbox/applications/Tools
% 
% 
% ITA-Toolbox/applications
% 
% 
% ITA-Toolbox
% 
% 
% ITA-Toolbox/kernel/ClassStuff
% 
%   display_line4commands                   <ITA-Toolbox>
%   ita_toolbox_classtree                   generates a tree of all ITA classes and saves it in ITA-Toolbox/pics
% 
% ITA-Toolbox/kernel/DSP/Analysis
% 
%   ita_normxcorr2                          calculates the normalized 2D cross-correlation
% 
% ITA-Toolbox/kernel/DSP/Arithmetic
% 
%   ita_invert_spk                          Invert your spk-data (1 ./ spk)
% 
% ITA-Toolbox/kernel/DSP/Edit
% 
%   ita_amplify_to                          Amplify itaAudio to specified dB-level (RMS over whole signal)
%   ita_liriFR                              Creates frequency response (FR) of a Linkwitz-Riley filter as itaAudioStruct
%   ita_xcorr_dat                           Calculates the cross-correlation in time-domain
% 
% ITA-Toolbox/kernel/DSP/Filter
% 
%   ita_filter_peak                         Peak/Bell-Filter / Parametric-EQ
% 
% ITA-Toolbox/kernel/DSP/Transformation
% 
%   ita_wiener_hopf_factorization           Do Wiener-Hopf Factorization
% 
% ITA-Toolbox/kernel/DSP
% 
% 
% ITA-Toolbox/kernel/DataAudio_IO
% 
%   ita_read                                This function reads supported files into the ITA-Toolbox class.
% 
% ITA-Toolbox/kernel/DataAudio_IO/ita_read
% 
%   ita_read_ita                            <ITA-Toolbox>
%   ita_read_unv                            returns the data of unv-files
%   ita_read_wav                            ITA_WAVREADRead Microsoft WAVE, WAV-EX and Ambisonics
% 
% ITA-Toolbox/kernel/DataAudio_IO
% 
%   ita_readunvgroups                       read groups from unv-files
%   ita_readunvresults                      Read unv-resultfile written with SoundSolve FE-Solver
%   ita_wavread                             Read Microsoft WAVE, WAV-EX and Ambisonics
% 
% ITA-Toolbox/kernel/DataAudio_IO/ita_write
% 
%   ita_write_unv                           writes data into unv-files
% 
% ITA-Toolbox/kernel/DataAudio_IO
% 
%   ita_write_txt                           Write audioObj to txt-File
% 
% ITA-Toolbox/kernel/Gui/Support
% 
% 
% ITA-Toolbox/kernel/Gui
% 
%   ita_guimenuentries                      ITA_GUISUPPORT_MENULISTCreate menu-entries
%   ita_plot_gui                            Part of the ITA-Toolbox GUI
%   ita_toolbox_gui                         <ITA-Toolbox>
%   ita_write_gui                           <ITA-Toolbox>
% 
% ITA-Toolbox/kernel/MetaInfo
% 
% 
% ITA-Toolbox/kernel/PlayrecMidi/ExternalPackages/playrec_2_1_1
% 
%   bformat_dec                             Decode a B-Format signal to a speaker feed
%   bformat_enc                             Encodes a mono signal into a B-Format signal
%   bformat_rot_tilt_tumble                 Rotate, tilt, and then tumble a B-Format signal
% 
% ITA-Toolbox/kernel/PlayrecMidi/ExternalPackages/playrec_2_1_1/m_files
% 
% 
% ITA-Toolbox/kernel/PlayrecMidi/ExternalPackages/playrec_2_1_1
% 
% 
% ITA-Toolbox/kernel/PlayrecMidi/ExternalPackages/rtmidi-1.0.12
% 
% 
% ITA-Toolbox/kernel/PlayrecMidi
% 
%   ita_midi_menuStr                        <ITA-Toolbox>
%   ita_playrec                             -
%   ita_playrec_show_strings                <ITA-Toolbox>
%   ita_portaudio                           Manages sound in- and output
%   ita_portmidi_menuStr                    <ITA-Toolbox>
%   ita_preferences_playrecmidi             <ITA-Toolbox>
% 
% ITA-Toolbox/kernel/PlotRoutines/Plottools
% 
%   ita_plottools_change_font_in_eps        Change font in an EPS-File
%   ita_plottools_ita_logo                  <ITA-Toolbox>
% 
% ITA-Toolbox/kernel/PlotRoutines/colormaps
% 
% 
% ITA-Toolbox/kernel/PlotRoutines
% 
%   ita_pcolor                              <ITA-Toolbox>
%   ita_pcolor_dB                           <ITA-Toolbox>
%   ita_plot_2D                             plot two-dimensional data
%   ita_plot_all                            multi-plot of the input object
%   ita_plot_ccx                            multi-plot of the input object
%   ita_plot_dat                            <ITA-Toolbox>
%   ita_plot_dat_dB                         <ITA-Toolbox>
%   ita_plot_spk                            <ITA-Toolbox>
%   ita_plot_spkgdelay                      <ITA-Toolbox>
%   ita_plot_spkphase                       <ITA-Toolbox>
%   ita_set_plot_preferences                <ITA-Toolbox>
% 
% ITA-Toolbox/kernel/StandardRoutines
% 
%   finfo                                   <ITA-Toolbox>
%   isincellstr                             This function compares two cell-arrays of strings
%   ita_check4toolboxsetup                  Call Toolbox Setup if out-of-date
%   ita_generateSampling_equiangular        <ITA-Toolbox>
%   ita_mapDataToMesh                       maps two-dimensional data onto a given mesh
%   ita_newm                                Open m-File with ITA Template
%   ita_questiondlg                         <ITA-Toolbox>
%   ita_restore_matlab_default_plot_preferences<ITA-Toolbox>
%   ita_toolbox_version_number              return the number of the current version of the ITA-Toolbox
%   ita_verbose_info                        Warning/ Informing Function of ITA-Toolbox
%   popup_index_to_string                   <ITA-Toolbox>
%   popup_string_to_index                   <ITA-Toolbox>
% 
% ITA-Toolbox/kernel
% 
%   ita_delete_toolboxpaths                 delete all ITA-Toolbox paths in MATLAB
%   ita_path_handling                       handle the ITA-toolbox paths in MATLAB
% 
% ITA-Toolbox/tutorials
% 
%   ita_tutorial                            Getting startet with the ITA-Toolbox
