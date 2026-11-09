function dst = add_sanitized_path(src)
% ADD_SANITIZED_PATH Copies the files of directory src to a temporary
% directory, replacing in .m files only the non-breaking space U+00A0 by an
% ASCII space, and puts the copy at the beginning of the path.
%   The original ARIsTEO sources contain U+00A0 on line 2 of each file,
%   which recent MATLAB releases (e.g. R2024b) reject as an "unsupported
%   non-ASCII whitespace character". The sources themselves are not changed.
    dst = tempname();
    mkdir(dst);
    files = dir(src);
    files = files(~[files.isdir]);
    for i = 1:numel(files)
        from = fullfile(src, files(i).name);
        to = fullfile(dst, files(i).name);
        [~, ~, ext] = fileparts(files(i).name);
        if strcmp(ext, '.m')
            txt = strrep(fileread(from), char(160), ' ');
            fid = fopen(to, 'w', 'n', 'UTF-8');
            fwrite(fid, txt, 'char');
            fclose(fid);
        else
            copyfile(from, to);
        end
    end
    addpath(dst, '-begin');
end
