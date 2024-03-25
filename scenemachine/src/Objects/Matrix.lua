local Math = SceneMachine.Math;
local Vector3 = SceneMachine.Vector3;
local Quaternion = SceneMachine.Quaternion;

SceneMachine.Matrix = 
{
    m00 = 0, m01 = 0, m02 = 0, m03 = 0,
    m10 = 0, m11 = 0, m12 = 0, m13 = 0,
    m20 = 0, m21 = 0, m22 = 0, m23 = 0,
    m30 = 0, m31 = 0, m32 = 0, m33 = 0
}

--- @class Matrix
local Matrix = SceneMachine.Matrix;

setmetatable(Matrix, Matrix)

local fields = {}

--- Creates a new Matrix object.
-- (c) Keanu Reeves
---@return Matrix v The newly created Matrix object.
function Matrix:New()
    local v = 
    {
        m00 = 0; m01 = 0; m02 = 0; m03 = 0;
        m10 = 0; m11 = 0; m12 = 0; m13 = 0;
        m20 = 0; m21 = 0; m22 = 0; m23 = 0;
        m30 = 0; m31 = 0; m32 = 0; m33 = 0;
    };

    setmetatable(v, Matrix)
    return v
end

--- Creates a perspective field of view matrix.
--- https://registry.khronos.org/OpenGL-Refpages/gl2.1/xhtml/gluPerspective.xml
--- @param fov number The field of view angle in --radians--.
--- @param aspectRatio number The aspect ratio of the viewport.
--- @param depthNear number The distance to the near clipping plane.
--- @param depthFar number The distance to the far clipping plane.
--- @return Matrix matrix The created perspective field of view matrix.
function Matrix:CreatePerspectiveFieldOfView(fov, aspectRatio, depthNear, depthFar)
    -- Calculate the scale factors
    local D2R = math.pi / 180.0;
    local yScale = 1.0 / math.tan(D2R * math.deg(fov) / 2);
    local xScale = yScale / aspectRatio;
    local nearmfar = depthNear - depthFar;

    -- Set the matrix elements
    self.m00 = xScale;
    self.m01 = 0;
    self.m02 = 0;
    self.m03 = 0;
    self.m10 = 0;
    self.m11 = yScale;
    self.m12 = 0;
    self.m13 = 0;
    self.m20 = 0;
    self.m21 = 0;
    self.m22 = (depthFar + depthNear) / nearmfar;
    self.m23 = -1;
    self.m30 = 0;
    self.m31 = 0;
    self.m32 = 2 * depthFar * depthNear / nearmfar;
    self.m33 = 0;

    return self;
end

--- Applies a transformation, rotation, and scaling to the matrix.
--- @param t Vector3 The translation vector.
--- @param r Quaternion The rotation quaternion.
--- @param s Vector3 The scaling vector.
function Matrix:TRS(t, r, s)
    self.m00 = (1.0-2.0*(r.y*r.y+r.z*r.z))*s.x;
    self.m01 = (r.x*r.y-r.z*r.w)*s.y*2.0;
    self.m02 = (r.x*r.z+r.y*r.w)*s.z*2.0;
    self.m03 = 0.0;
    
    self.m10 = (r.x*r.y+r.z*r.w)*s.x*2.0;
    self.m11 = (1.0-2.0*(r.x*r.x+r.z*r.z))*s.y;
    self.m12 = (r.y*r.z-r.x*r.w)*s.z*2.0;
    self.m13 = 0.0;
    
    self.m20 = (r.x*r.z-r.y*r.w)*s.x*2.0;
    self.m21 = (r.y*r.z+r.x*r.w)*s.y*2.0;
    self.m22 = (1.0-2.0*(r.x*r.x+r.y*r.y))*s.z;
    self.m23 = 0.0;
    
    self.m30 = t.x;
    self.m31 = t.y;
    self.m32 = t.z;
    self.m33 = 1.0;
end

--- Sets the matrix to a look-at transformation.
--- @param eye Vector3 The position of the camera.
--- @param target Vector3 The position to look at.
--- @param up Vector3 The up direction.
--- @return Matrix matrix The modified matrix.
function Matrix:LookAt(eye, target, up)
    local z = Vector3:New();
    z:SetVector3(eye);
    z:Subtract(target);
    z:Normalize();

    local x = Vector3:New();
    x:SetVector3(up);
    x:CrossProduct(z);
    x:Normalize();

    local y = Vector3:New();
    y:SetVector3(z);
    y:CrossProduct(x);
    y:Normalize();

    self.m00 = -x.x;
    self.m01 = -x.y;
    self.m02 = -x.z;
    self.m03 = Vector3.DotProduct(x, eye);

    self.m10 = y.x;
    self.m11 = y.y;
    self.m12 = y.z;
    self.m13 = -Vector3.DotProduct(y, eye);

    self.m20 = z.x;
    self.m21 = z.y;
    self.m22 = z.z;
    self.m23 = -Vector3.DotProduct(z, eye);
    
    self.m30 = 0;
    self.m31 = 0;
    self.m32 = 0;
    self.m33 = 1;

    return self;
end

--- Inverts the matrix.
--- @return Matrix? matrix The inverted matrix, or nil if the matrix is not invertible.
function Matrix:Invert()
    -- Extract matrix elements for easier access
    local m00, m01, m02, m03 = self.m00, self.m01, self.m02, self.m03
    local m10, m11, m12, m13 = self.m10, self.m11, self.m12, self.m13
    local m20, m21, m22, m23 = self.m20, self.m21, self.m22, self.m23
    local m30, m31, m32, m33 = self.m30, self.m31, self.m32, self.m33

    -- Calculate the determinant of the matrix
    local det = m00 * (m11 * (m22 * m33 - m32 * m23) - m12 * (m21 * m33 - m31 * m23) + m13 * (m21 * m32 - m31 * m22)) -
                m01 * (m10 * (m22 * m33 - m32 * m23) - m12 * (m20 * m33 - m30 * m23) + m13 * (m20 * m32 - m30 * m22)) +
                m02 * (m10 * (m21 * m33 - m31 * m23) - m11 * (m20 * m33 - m30 * m23) + m13 * (m20 * m31 - m30 * m21)) -
                m03 * (m10 * (m21 * m32 - m31 * m22) - m11 * (m20 * m32 - m30 * m22) + m12 * (m20 * m31 - m30 * m21))

    -- Check if the matrix is invertible
    if det == 0 then
        return nil -- Matrix is not invertible
    end

    -- Calculate the inverse determinant
    local invDet = 1 / det

    -- Calculate the inverted matrix elements
    self.m00 = (m11 * (m22 * m33 - m32 * m23) - m12 * (m21 * m33 - m31 * m23) + m13 * (m21 * m32 - m31 * m22)) * invDet
    self.m01 = -(m01 * (m22 * m33 - m32 * m23) - m02 * (m21 * m33 - m31 * m23) + m03 * (m21 * m32 - m31 * m22)) * invDet
    self.m02 = (m01 * (m12 * m33 - m32 * m13) - m02 * (m11 * m33 - m31 * m13) + m03 * (m11 * m32 - m31 * m12)) * invDet
    self.m03 = -(m01 * (m12 * m23 - m22 * m13) - m02 * (m11 * m23 - m21 * m13) + m03 * (m11 * m22 - m21 * m12)) * invDet

    self.m10 = -(m10 * (m22 * m33 - m32 * m23) - m12 * (m20 * m33 - m30 * m23) + m13 * (m20 * m32 - m30 * m22)) * invDet
    self.m11 = (m00 * (m22 * m33 - m32 * m23) - m02 * (m20 * m33 - m30 * m23) + m03 * (m20 * m32 - m30 * m22)) * invDet
    self.m12 = -(m00 * (m12 * m33 - m32 * m13) - m02 * (m10 * m33 - m30 * m13) + m03 * (m10 * m32 - m30 * m12)) * invDet
    self.m13 = (m00 * (m12 * m23 - m22 * m13) - m02 * (m10 * m23 - m20 * m13) + m03 * (m10 * m22 - m20 * m12)) * invDet

    self.m20 = (m10 * (m21 * m33 - m31 * m23) - m11 * (m20 * m33 - m30 * m23) + m13 * (m20 * m31 - m30 * m21)) * invDet
    self.m21 = -(m00 * (m21 * m33 - m31 * m23) - m01 * (m20 * m33 - m30 * m23) + m03 * (m20 * m31 - m30 * m21)) * invDet
    self.m22 = (m00 * (m11 * m33 - m31 * m13) - m01 * (m10 * m33 - m30 * m13) + m03 * (m10 * m31 - m30 * m11)) * invDet
    self.m23 = -(m00 * (m11 * m23 - m21 * m13) - m01 * (m10 * m23 - m20 * m13) + m03 * (m10 * m21 - m20 * m11)) * invDet

    self.m30 = -(m10 * (m21 * m32 - m31 * m22) - m11 * (m20 * m32 - m30 * m22) + m12 * (m20 * m31 - m30 * m21)) * invDet
    self.m31 = (m00 * (m21 * m32 - m31 * m22) - m01 * (m20 * m32 - m30 * m22) + m02 * (m20 * m31 - m30 * m21)) * invDet
    self.m32 = -(m00 * (m11 * m32 - m31 * m12) - m01 * (m10 * m32 - m30 * m12) + m02 * (m10 * m31 - m30 * m11)) * invDet
    self.m33 = (m00 * (m11 * m22 - m21 * m12) - m01 * (m10 * m22 - m20 * m12) + m02 * (m10 * m21 - m20 * m11)) * invDet

    return self;
end

--- Decomposes the matrix into its position, rotation, and scale components.
--- @return Vector3 position, Quaternion qRotation, number scale The position, rotation, scale component of the matrix.
function Matrix:Decompose()
    local position = self:ExtractPosition();
    local qRotation = self:ExtractRotation();
    local scale = self:ExtractScale();

    return position, qRotation, scale;
end

--- Extracts the position from the matrix.
--- @return Vector3 position The extracted position as a Vector3.
function Matrix:ExtractPosition()
    -- Extract translation
    local tx = self.m30
    local ty = self.m31
    local tz = self.m32

    return Vector3:New(tx, ty, tz);
end

--- Returns the normalized rows of a 3x3 matrix.
--- Each row is normalized by dividing its elements by the length of the row.
--- @return number m00, number m01, number m02, number m10, number m11, number m12, number m20, number m21, number m22 The normalized rows of the matrix.
function Matrix:GetNormalizedRows3x3()
    local m00, m01, m02, m03 = self.m00, self.m01, self.m02, self.m03
    local m10, m11, m12, m13 = self.m10, self.m11, self.m12, self.m13
    local m20, m21, m22, m23 = self.m20, self.m21, self.m22, self.m23

    local length = math.sqrt(m00 * m00 + m01 * m01 + m02 * m02 + m03 * m03)
    m00 = m00 / length
    m01 = m01 / length
    m02 = m02 / length

    length = math.sqrt(m10 * m10 + m11 * m11 + m12 * m12 + m13 * m13)
    m10 = m10 / length
    m11 = m11 / length
    m12 = m12 / length

    length = math.sqrt(m20 * m20 + m21 * m21 + m22 * m22 + m23 * m23)
    m20 = m20 / length
    m21 = m21 / length
    m22 = m22 / length

    return m00, m01, m02, m10, m11, m12, m20, m21, m22
end

--- Extracts the rotation component from the matrix and returns it as a quaternion.
--- @return Quaternion rotation The extracted rotation as a quaternion.
function Matrix:ExtractRotation()
    local m00, m01, m02, m10, m11, m12, m20, m21, m22 = self:GetNormalizedRows3x3();

    local q = Quaternion:New();
    local trace = 0.25 * (m00 + m11 + m22 + 1.0);

    if trace > 0 then
        local sq = math.sqrt(trace);
        q.w = sq;
        sq = 1.0 / (4.0 * sq);
        q.x = (m12 - m21) * sq;
        q.y = (m20 - m02) * sq;
        q.z = (m01 - m10) * sq;
    elseif m00 > m11 and m00 > m22 then
        local sq = 2.0 * math.sqrt(1.0 + m00 - m11 - m22);
        q.x = 0.25 * sq;
        sq = 1.0 / sq;
        q.w = (m12 - m21) * sq;
        q.y = (m10 + m01) * sq;
        q.z = (m20 + m02) * sq;
    elseif m11 > m22 then
        local sq = 2.0 * math.sqrt(1.0 + m11 - m00 - m22);
        q.y = 0.25 * sq;
        sq = 1.0 / sq;
        q.w = (m20 - m02) * sq;
        q.x = (m10 + m01) * sq;
        q.z = (m21 + m12) * sq;
    else
        local sq = 2.0 * math.sqrt(1.0 + m22 - m00 - m11);
        q.z = 0.25 * sq;
        sq = 1.0 / sq;
        q.w = (m01 - m10) * sq;
        q.x = (m20 + m02) * sq;
        q.y = (m21 + m12) * sq;
    end

    q:Normalize();
    return q;
end

--- Extracts the scale from the matrix.
--- @return number scale The average scale value.
function Matrix:ExtractScale()
    local sx = Vector3:New(self.m00, self.m10, self.m20):Length();
    local sy = Vector3:New(self.m01, self.m11, self.m21):Length();
    local sz = Vector3:New(self.m02, self.m12, self.m22):Length();
    return (sx + sy + sz) / 3;
end

--- Sets the values of the matrix using another matrix.
---@param m Matrix The matrix to set the values from.
function Matrix:SetMatrix(m)
    self.m00 = m.m00;
    self.m01 = m.m01;
    self.m02 = m.m02;
    self.m03 = m.m03;

    self.m10 = m.m10;
    self.m11 = m.m11;
    self.m12 = m.m12;
    self.m13 = m.m13;

    self.m20 = m.m20;
    self.m21 = m.m21;
    self.m22 = m.m22;
    self.m23 = m.m23;

    self.m30 = m.m30;
    self.m31 = m.m31;
    self.m32 = m.m32;
    self.m33 = m.m33;
end

--- Sets the matrix to the identity matrix.
function Matrix:SetIdentity()
    self.m00, self.m01, self.m02, self.m03 = 1, 0, 0, 0
    self.m10, self.m11, self.m12, self.m13 = 0, 1, 0, 0
    self.m20, self.m21, self.m22, self.m23 = 0, 0, 1, 0
    self.m30, self.m31, self.m32, self.m33 = 0, 0, 0, 1
end

--- Translates the matrix by the specified position.
--- @param position Vector3 The position to translate the matrix by.
function Matrix:Translate(position)
    self.m30 = position.x
    self.m31 = position.y
    self.m32 = position.z
end

--- Rotates the matrix using a quaternion.
--- Adapted from https://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation#Quaternion-derived_rotation_matrix
---@param q table The quaternion to rotate the matrix with.
function Matrix:RotateQuaternion(q)
    local sqx = q.x * q.x
    local sqy = q.y * q.y
    local sqz = q.z * q.z
    local sqw = q.w * q.w

    local xy = q.x * q.y
    local xz = q.x * q.z
    local xw = q.x * q.w

    local yz = q.y * q.z
    local yw = q.y * q.w

    local zw = q.z * q.w

    local s2 = 2 / (sqx + sqy + sqz + sqw)

    self.m00 = 1 - s2 * (sqy + sqz)
    self.m01 = s2 * (xy + zw)
    self.m02 = s2 * (xz - yw)
    self.m03 = 0

    self.m10 = s2 * (xy - zw)
    self.m11 = 1 - s2 * (sqx + sqz)
    self.m12 = s2 * (yz + xw)
    self.m13 = 0

    self.m20 = s2 * (xz + yw)
    self.m21 = s2 * (yz - xw)
    self.m22 = 1 - s2 * (sqx + sqy)
    self.m23 = 0

    self.m30 = 0
    self.m31 = 0
    self.m32 = 0
    self.m33 = 1
end

--- Scales the matrix by the specified scale vector.
--- @param scale Vector3 The scale vector.
function Matrix:Scale(scale)
    self.m00 = scale.x;
    self.m11 = scale.y;
    self.m22 = scale.z;
end

--- Multiplies the current matrix with another matrix.
--- @param o Matrix The other matrix to multiply with.
function Matrix:Multiply(o)
    local m = self

    local m00 = m.m00 * o.m00 + m.m01 * o.m10 + m.m02 * o.m20 + m.m03 * o.m30
    local m01 = m.m00 * o.m01 + m.m01 * o.m11 + m.m02 * o.m21 + m.m03 * o.m31
    local m02 = m.m00 * o.m02 + m.m01 * o.m12 + m.m02 * o.m22 + m.m03 * o.m32
    local m03 = m.m00 * o.m03 + m.m01 * o.m13 + m.m02 * o.m23 + m.m03 * o.m33
    
    local m10 = m.m10 * o.m00 + m.m11 * o.m10 + m.m12 * o.m20 + m.m13 * o.m30
    local m11 = m.m10 * o.m01 + m.m11 * o.m11 + m.m12 * o.m21 + m.m13 * o.m31
    local m12 = m.m10 * o.m02 + m.m11 * o.m12 + m.m12 * o.m22 + m.m13 * o.m32
    local m13 = m.m10 * o.m03 + m.m11 * o.m13 + m.m12 * o.m23 + m.m13 * o.m33
    
    local m20 = m.m20 * o.m00 + m.m21 * o.m10 + m.m22 * o.m20 + m.m23 * o.m30
    local m21 = m.m20 * o.m01 + m.m21 * o.m11 + m.m22 * o.m21 + m.m23 * o.m31
    local m22 = m.m20 * o.m02 + m.m21 * o.m12 + m.m22 * o.m22 + m.m23 * o.m32
    local m23 = m.m20 * o.m03 + m.m21 * o.m13 + m.m22 * o.m23 + m.m23 * o.m33
    
    local m30 = m.m30 * o.m00 + m.m31 * o.m10 + m.m32 * o.m20 + m.m33 * o.m30
    local m31 = m.m30 * o.m01 + m.m31 * o.m11 + m.m32 * o.m21 + m.m33 * o.m31
    local m32 = m.m30 * o.m02 + m.m31 * o.m12 + m.m32 * o.m22 + m.m33 * o.m32
    local m33 = m.m30 * o.m03 + m.m31 * o.m13 + m.m32 * o.m23 + m.m33 * o.m33

    m.m00, m.m01, m.m02, m.m03 = m00, m01, m02, m03
    m.m10, m.m11, m.m12, m.m13 = m10, m11, m12, m13
    m.m20, m.m21, m.m22, m.m23 = m20, m21, m22, m23
    m.m30, m.m31, m.m32, m.m33 = m30, m31, m32, m33
end

-- This function is used as the __index metamethod for the Matrix table.
-- It is called when a key is not found in the Matrix table.
Matrix.__index = function(t,k)
	local var = rawget(Matrix, k)
		
	if var == nil then							
		var = rawget(fields, k)
		
		if var ~= nil then
			return var(t)	
		end
	end
	
	return var
end