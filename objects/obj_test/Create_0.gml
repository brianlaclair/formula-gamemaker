// Load the OBJ file and use it to create a compatible object for FormulaRenderer
var model_file_buffer = buffer_load("teapot.obj");
var model_file_string = buffer_read(model_file_buffer, buffer_string);
buffer_delete(model_file_buffer);

// Create the FormulaRenderer-compatible model
var model = new ObjModel(model_file_string);


// Create the renderer for the model
renderer = new FormulaRenderer(model);

angle = 0;
rotate_speed = 0.1;
distance = 4.8;