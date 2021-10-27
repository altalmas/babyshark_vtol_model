classdef AircraftVisualizer
    properties
        stl_model
        model_vertices
        model_faces
        cg_position_from_front = -0.494;
        cg_position_from_bottom = 0.25;
    end
    
    methods
        function obj = AircraftVisualizer()
            obj.stl_model = stlread('3d_files/babyshark.stl');
            obj = obj.initialize_aircraft_model();
        end
        function obj = initialize_aircraft_model(obj)
            % Import an STL mesh, returning a PATCH-compatible face-vertex structure
            V = obj.stl_model.vertices;
            obj.model_faces = obj.stl_model.faces;

            % Rotate the aircraft to initial position, with positive x-axis out of nose
            initial_phi = pi/2;
            initial_theta = 0;
            initial_psi = pi/2;
            V = obj.rotate_vertices(V, initial_phi, initial_theta, initial_psi);

            % Scale the aircraft to the correct size
            wingspan = 2.5;
            V = obj.scale_aircraft(wingspan, V);

            % Move origin to front of aircraft nose
            temp_max = max(V);
            temp_min = min(V);
            ranges = abs(temp_max - temp_min);
            aircraft_length = ranges(1);
            V = V - [aircraft_length wingspan/2 0];

            % Move origin to cg
            cg_position = [obj.cg_position_from_front 0 obj.cg_position_from_bottom];
            V = V - cg_position; 
            
            obj.model_vertices = V;
        end
        
        function V_scaled = scale_aircraft(~, wingspan, V)
            temp_max = max(V);
            temp_min = min(V);
            ranges = abs(temp_max - temp_min);
            y_range = ranges(2);
            scaling_factor = y_range / wingspan;
            V_scaled = V / scaling_factor;
        end
        
        function V_rotated = rotate_vertices(~, V, phi, theta, psi)
            Rx = [1 0 0;
                  0 cos(phi) -sin(phi);
                  0 sin(phi) cos(phi)];

            Ry = [cos(theta) 0 sin(theta);
                  0 1 0;
                  -sin(theta) 0 cos(theta)];

            Rz = [cos(psi), -sin(psi), 0 ;
                  sin(psi), cos(psi), 0 ;
                         0,         0, 1 ];

            V_rotated = V * Rx';
            V_rotated = V_rotated * Ry';
            V_rotated = V_rotated * Rz';
        end
        
        function set_render_settings(~)
            % Add a camera light, and tone down the specular highlighting
            camlight('headlight');
            material('dull');

            % Fix the axes scaling, and set a nice view angle
            axis('image');
            %view(view_angle);
            xlabel('x [m]')
            ylabel('y [m]')
            zlabel('z [m]')
            grid on
        end
        
        function plot_aircraft(obj)
            patch('Faces', obj.model_faces, 'Vertices', obj.model_vertices, ...
                 'FaceColor',       [0.8 0.8 1.0], ...
                 'EdgeColor',       'none',        ...
                 'FaceLighting',    'gouraud',     ...
                 'AmbientStrength', 0.15); hold on
        end
    end
end

