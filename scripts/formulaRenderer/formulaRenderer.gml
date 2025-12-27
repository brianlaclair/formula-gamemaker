function ObjModel(_obj_string) constructor 
{
    vs = [];
    fs = [];

    var _lines = string_split(_obj_string, "\n", true);
    var _line_count = array_length(_lines);

    for (var i = 0; i < _line_count; i++) {
        var _line = string_trim(_lines[i]);

        if (_line == "" || string_char_at(_line, 1) == "#") continue;

        var _parts = string_split(_line, " ", true);
        var _type = _parts[0];

        if (_type == "v") {
            array_push(vs, {
                x: real(_parts[1]),
                y: real(_parts[2]),
                z: real(_parts[3])
            });
        } else if (_type == "f") {
            var _face_indices = [];
            var _num_verts = array_length(_parts);
            
            for (var j = 1; j < _num_verts; j++) {
                var _indices = string_split(_parts[j], "/");
                var _v_idx = real(_indices[0]) - 1;
                array_push(_face_indices, _v_idx);
            }
            array_push(fs, _face_indices);
        }
    }

    var _vs_len = array_length(vs);
    
    if (_vs_len > 0) {
        var _min_x = 999999999; var _max_x = -999999999;
        var _min_y = 999999999; var _max_y = -999999999;
        var _min_z = 999999999; var _max_z = -999999999;

        for (var i = 0; i < _vs_len; i++) {
            var _v = vs[i];
            _min_x = min(_min_x, _v.x); _max_x = max(_max_x, _v.x);
            _min_y = min(_min_y, _v.y); _max_y = max(_max_y, _v.y);
            _min_z = min(_min_z, _v.z); _max_z = max(_max_z, _v.z);
        }

        var _cx = (_min_x + _max_x) / 2;
        var _cy = (_min_y + _max_y) / 2;
        var _cz = (_min_z + _max_z) / 2;

        for (var i = 0; i < _vs_len; i++) {
            vs[i].x -= _cx;
            vs[i].y -= _cy;
            vs[i].z -= _cz;
        }
    }
}

function FormulaRenderer(object = {fs: [], vs: []}) constructor 
{
    fs = object.fs;
    vs = object.vs;
    
    fs_length = array_length(fs);
    vs_length = array_length(vs);
    
    rw_half = room_width / 2;
    rh_half = room_height / 2;
    
    cache_x = array_create(vs_length);
    cache_y = array_create(vs_length);
    cache_z = array_create(vs_length);

    draw = function (angle = 0, dz = 1) {
		
		var _orig_alpha = draw_get_alpha();
        
        var _c = cos(angle);
        var _s = sin(angle);
        
        for (var i = 0; i < vs_length; i++) {
            var _v = vs[i];
            
            var _rx = _v.x * _c - _v.z * _s;
            var _rz = _v.x * _s + _v.z * _c;
            
            var _tz = _rz + dz;
            
            // Prevent divide-by-zero errors if object is at camera Z
            if (_tz == 0) _tz = 0.0001;
            
            cache_x[i] = ((_rx / _tz) + 1) * rw_half;
            cache_y[i] = (1 - (_v.y / _tz)) * rh_half;
            cache_z[i] = _tz; // Addition: store Z for line width calculation
        }
        
        for (var f = 0; f < fs_length; f++) {
            
            var _face = fs[f];
            var _face_len = array_length(_face);
            
            var _idx1 = _face[_face_len - 1];
            
            var _x1 = cache_x[_idx1];
            var _y1 = cache_y[_idx1];
            var _z1 = cache_z[_idx1];

            for (var i = 0; i < _face_len; i++) {
                var _idx2 = _face[i];
                
                var _x2 = cache_x[_idx2];
                var _y2 = cache_y[_idx2];

                var _size = clamp(abs(2 / _z1), 0, 10); 
                
                draw_set_alpha(_size / 5);
                draw_line_width(_x1, _y1, _x2, _y2, _size);
                
                _idx1 = _idx2;
                _x1 = _x2;
                _y1 = _y2;
                _z1 = cache_z[_idx2];
            }
        }
        
        draw_set_alpha(_orig_alpha);
    }
}