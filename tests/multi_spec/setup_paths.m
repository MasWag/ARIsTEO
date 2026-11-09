function src_dir = setup_paths(aristeo_dir)
% SETUP_PATHS Adds S-TaLiRo and the given ARIsTEO source directory to the path.
%   setup_paths()            uses the ARIsTEO directory of this repository
%   setup_paths(aristeo_dir) uses another ARIsTEO source directory (e.g. a
%                            checkout of master for regression comparisons)
%   The S-TaLiRo location can be overridden with the STALIRO_DIR variable.
%
%   The ARIsTEO sources are put on the path through a temporary copy in
%   which only U+00A0 is replaced by a space (see add_sanitized_path); its
%   location is returned.
    here = fileparts(mfilename('fullpath'));
    if nargin < 1 || isempty(aristeo_dir)
        aristeo_dir = fullfile(here, '..', '..', 'ARIsTEO');
    end
    staliro_dir = getenv('STALIRO_DIR');
    if isempty(staliro_dir)
        staliro_dir = '/opt/aristeo/ARIsTEO/staliro';
    end
    % S-TaLiRo without its demos: staliro/demos/"RRTs for Testing ADS"/src/
    % modifications_to_staliro contains an incompatible SA_Taliro.m and
    % Compute_Robustness*.m which would otherwise shadow the real ones and
    % make every surrogate search fail ("too many output arguments").
    dirs = strsplit(genpath(staliro_dir), pathsep);
    dirs = dirs(~cellfun(@isempty, dirs) & ~contains(dirs, [filesep 'demos']));
    addpath(dirs{:});

    src_dir = add_sanitized_path(aristeo_dir);
    addpath(here);
    assert(strcmp(fileparts(which('aristeo')), src_dir), ...
        'aristeo resolves to %s instead of %s', which('aristeo'), src_dir);
end
