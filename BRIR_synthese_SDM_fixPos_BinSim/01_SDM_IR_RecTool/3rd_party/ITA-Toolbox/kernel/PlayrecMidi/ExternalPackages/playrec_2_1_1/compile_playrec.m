function compile_playrec

% Make sure we can see external m files, even if this file is not in the
% current working directory but on the path somewhere
mfilepath = mfilename('fullpath');
mfilepath = mfilepath(1:end-length(mfilename));

addpath([mfilepath,'m_files'])

pa_path = find_folder(mfilepath, '.*portaudio.*', {'src/common', ...
                                                 'src/hostapi', ...
                                                 'src/os', ...
                                                 'include' ...
                                                }, 5);
if is_os('WIN') || is_os('MAC')
    asio_path = find_folder(mfilepath, '.*asio.*', {'common',  ...
                                                    'host' ...
                                                   }, 5);
else
    asio_path = '';
end

if is_os('WIN')
    dsound_path = find_folder(mfilepath, '.*directx.*', {'include',  ...
                                                        'lib/x86/dsound.lib' ...
                                                       }, 5);

    if isempty(dsound_path) && ~isempty(getenv('PROGRAMFILES')) ...
            && exist(getenv('PROGRAMFILES'), 'dir')

        dsound_path = find_folder(getenv('PROGRAMFILES'), ...
                                   '.*directx.*', ...
                                   {'include', 'lib/x86/dsound.lib'},  ...
                                   1);
    end

    if isempty(dsound_path) && ~isempty(getenv('HOMEDRIVE')) ...
            && exist(getenv('HOMEDRIVE'), 'dir')
    
        dsound_path = find_folder(getenv('HOMEDRIVE'),  ...
                                   '.*directx.*',  ...
                                   {'include', 'lib/x86/dsound.lib'}, ...
                                   1);
    end
else
    dsound_path = '';
end

if isempty(asio_path)
    asio_path = ' ';
end

if is_octave
    compile_playrec_cmd(asio_path, dsound_path, pa_path);
else
    compile_playrec_gui(asio_path, dsound_path, pa_path);
end
