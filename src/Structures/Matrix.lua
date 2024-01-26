local Math = SceneMachine.Math;
local Vector3 = SceneMachine.Vector3;

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
    local FOV_CORRECTION = 0.97;
    local top = depthNear * math.tan(0.5 * fov * FOV_CORRECTION);
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

function Matrix:TRS(t, r, s)
    self.m00 = (1.0-2.0*(r[2]*r[2]+r[3]*r[3]))*s[1];
    self.m10 = (r[1]*r[2]+r[3]*r[4])*s[1]*2.0;
    self.m20 = (r[1]*r[3]-r[2]*r[4])*s[1]*2.0;
    self.m30 = 0.0;
    self.m01 = (r[1]*r[2]-r[3]*r[4])*s[2]*2.0;
    self.m11 = (1.0-2.0*(r[1]*r[1]+r[3]*r[3]))*s[2];
    self.m21 = (r[2]*r[3]+r[1]*r[4])*s[2]*2.0;
    self.m31 = 0.0;
    self.m02 = (r[1]*r[3]+r[2]*r[4])*s[3]*2.0;
    self.m12 = (r[2]*r[3]-r[1]*r[4])*s[3]*2.0;
    self.m22 = (1.0-2.0*(r[1]*r[1]+r[2]*r[2]))*s[3];
    self.m32 = 0.0;
    self.m03 = t[1];
    self.m13 = t[2];
    self.m23 = t[3];
    self.m33 = 1.0;
end

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