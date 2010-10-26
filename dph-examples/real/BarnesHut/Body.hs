{-# LANGUAGE BangPatterns #-}

-- | Massful bodies in the simulation.
module Body
	( Velocity
	, Accel
	, MassPoint
	, Body
	
	, accel

	, unitBody
	, massPointOfBody
	, setMassOfBody
	, setAccelOfBody
	, setStartVelOfBody
	, advanceBody)
where
import Util


-- Types ----------------------------------------------------------------------
-- We're using tuples instead of ADTs so we can put them in unboxed vectors.

-- | The velocity of a point.
type Velocity	= (Double, Double)

-- | The acceleration of a point.
type Accel	= (Double, Double)

-- | A point in 2D space with its mass.
type MassPoint	= (Double, Double, Double)

-- | Bodies consist of a MassPoint, but also carry their velocity
--   and acceleration between steps of the simulation.
type Body	= (MassPoint, Velocity, Accel)


-- Acceleration ---------------------------------------------------------------
-- | Calculate the acceleration on a point due to some other point.
accel 	:: Double 	-- ^ If the distance between the points is smaller than this
			--   then ignore the forces between them.
	-> MassPoint	-- ^ The point being acclerated.
	-> MassPoint	-- ^ Neibouring point.
	-> Accel

{-# INLINE accel #-}
accel epsilon (!x1, !y1, _) (!x2, !y2, !m)  
	| otherwise	= (aabs * dx / r , aabs * dy / r)  
        where	rsqr = (dx * dx) + (dy * dy) + epsilon
		r    = sqrt rsqr 
		dx   = x1 - x2 
		dy   = y1 - y2 
		aabs = m / rsqr 


-- Body -----------------------------------------------------------------------
-- | Make a body with unit mass and zero vel and acc.
unitBody :: Double -> Double -> Body
unitBody x y
	= ((x, y, 1), (0, 0), (0, 0))


-- | Take the MassPoint of a body.
massPointOfBody :: Body -> MassPoint
massPointOfBody (mp, vel, acc)	
	= mp


-- | Set the mass of a body.
setMassOfBody :: Double -> Body -> Body
setMassOfBody mass ((x, y, _), vel, acc)
	= ((x, y, mass), vel, acc)


-- | Set the acceleration of a body.
setAccelOfBody :: Accel -> Body -> Body
setAccelOfBody acc' (mp, vel, _)	
	= (mp, vel, acc')

	
-- | Set the starting velocity of a body.
--   It is set to rotate around the origin, with the speed proportional
--   to the sqrt of the distance from it. This seems to make nice simulations.
setStartVelOfBody :: Double -> Body -> Body
setStartVelOfBody startVel (mp@(x, y, mass), vel, acc)
 = let	pos		= (x, y)
	(x', y')	= normaliseV (x, y)
   	vel'		= (y', -x')
	vel''		= mulSV (sqrt (magV pos) * startVel) vel'
	
   in	(mp, vel'', acc)


-- | Advance a body forwards in time.
advanceBody :: Double -> Body -> Body
advanceBody time 
	( (px, py, mass) 
	, (vx, vy) 
	, acc@(ax, ay))

  =	( (px + time * vx, py + time * vy, mass)
	, (vx + time * ax, vy + time * ay)
	, acc)
