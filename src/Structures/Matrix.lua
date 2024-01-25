local Math = SceneMachine.Math;

SceneMachine.Matrix = 
{
    m00 = 0, m01 = 0, m02 = 0, m03 = 0,
    m10 = 0, m11 = 0, m12 = 0, m13 = 0,
    m20 = 0, m21 = 0, m22 = 0, m23 = 0,
    m30 = 0, m31 = 0, m32 = 0, m33 = 0
}

local Matrix = SceneMachine.Matrix;

setmetatable(Matrix, Matrix)

local fields = {}

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

function Matrix:CreatePerspectiveFieldOfView(fov, aspectRatio, depthNear, depthFar)
    local top = depthNear * math.tan(0.5 * fov);
    local bottom = -top;
    local left = bottom * aspectRatio;
    local right = top * aspectRatio;

    local x = 2.0 * depthNear / (right - left);
    local y = 2.0 * depthNear / (top - bottom);
    local a = (right + left) / (right - left);
    local b = (top + bottom) / (top - bottom);
    local c = -(depthFar + depthNear) / (depthFar - depthNear);
    local d = -(2.0 * depthFar * depthNear) / (depthFar - depthNear);

    self.m00 = x;
    self.m01 = 0;
    self.m02 = 0;
    self.m03 = 0;
    self.m10 = 0;
    self.m11 = y;
    self.m12 = 0;
    self.m13 = 0;
    self.m20 = a;
    self.m21 = b;
    self.m22 = c;
    self.m23 = -1;
    self.m30 = 0;
    self.m31 = 0;
    self.m32 = d;
    self.m33 = 0;

    return self;
end

function Matrix:CreateCameraViewMatrix(position, target, up)
    local forward = Math.normalizeVector3({target[1] - position[1], target[2] - position[2], target[3] - position[3]})
    local right = Math.normalizeVector3(Math.crossProduct(up, forward))
    local newUp = Math.crossProduct(forward, right)

    self.m00 = right[1];
    self.m01 = right[2];
    self.m02 = right[3];
    self.m03 = -Math.dotProductVec3(right, position);
    self.m10 = newUp[1];
    self.m11 = newUp[2];
    self.m12 = newUp[3];
    self.m13 = -Math.dotProductVec3(newUp, position);
    self.m20 = -forward[1];
    self.m21 = -forward[2];
    self.m22 = -forward[3];
    self.m23 = Math.dotProductVec3(forward, position);
    self.m30 = 0;
    self.m31 = 0;
    self.m32 = 0;
    self.m33 = 1;

    return self;
end

function Matrix:Invert()
    local m00, m01, m02, m03 = self.m00, self.m01, self.m02, self.m03
    local m10, m11, m12, m13 = self.m10, self.m11, self.m12, self.m13
    local m20, m21, m22, m23 = self.m20, self.m21, self.m22, self.m23
    local m30, m31, m32, m33 = self.m30, self.m31, self.m32, self.m33

    local det = m00 * (m11 * (m22 * m33 - m32 * m23) - m12 * (m21 * m33 - m31 * m23) + m13 * (m21 * m32 - m31 * m22)) -
                m01 * (m10 * (m22 * m33 - m32 * m23) - m12 * (m20 * m33 - m30 * m23) + m13 * (m20 * m32 - m30 * m22)) +
                m02 * (m10 * (m21 * m33 - m31 * m23) - m11 * (m20 * m33 - m30 * m23) + m13 * (m20 * m31 - m30 * m21)) -
                m03 * (m10 * (m21 * m32 - m31 * m22) - m11 * (m20 * m32 - m30 * m22) + m12 * (m20 * m31 - m30 * m21))

    if det == 0 then
        return nil -- Matrix is not invertible
    end

    local invDet = 1 / det

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

function Matrix:MultiplyVector(vector)
    local result = {
        self.m00 * vector[1] + self.m01 * vector[2] + self.m02 * vector[3] + self.m03 * vector[4],
        self.m10 * vector[1] + self.m11 * vector[2] + self.m12 * vector[3] + self.m13 * vector[4],
        self.m20 * vector[1] + self.m21 * vector[2] + self.m22 * vector[3] + self.m23 * vector[4],
        self.m30 * vector[1] + self.m31 * vector[2] + self.m32 * vector[3] + self.m33 * vector[4]
    }

    return result
end

--function Matrix:GetFileID()
--    return self.fileID;
--end
--
--function Matrix:SetPosition(x, y, z)
--    self.position.x = x;
--    self.position.y = y;
--    self.position.z = z;
--    
--    -- apply to actor
--    if (self.actor ~= nil) then
--        local s = self.scale;
--        self.actor:SetPosition(x / s, y / s, z / s);
--    end
--end

--Matrix.__tostring = function(self)
--	return string.format("%s %i p(%f,%f,%f)", self.name, self.fileID, self.position.x, self.position.y, self.position.z);
--end

--Matrix.__eq = function(a,b)
--    return a.id == b.id;
--end

-- Set multiply "*" behaviour
--Matrix.__mul = function( m1,m2 )
--	if getmetatable( m1 ) ~= matrix_meta then
--		return matrix.mulnum( m2,m1 )
--	elseif getmetatable( m2 ) ~= matrix_meta then
--		return matrix.mulnum( m1,m2 )
--	end
--	return matrix.mul( m1,m2 )
--end

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