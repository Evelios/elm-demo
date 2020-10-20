module Picture exposing (drawing)

{-| Drawings should be centered around the origin (0, 0). The drawing height
and width should extend equally from either side. The max height and width
should therefore be (height/2, width/2).
-}

import Angle
import BoundingBox2d exposing (BoundingBox2d)
import Geometry.Svg
import Point2d
import Quantity
import Size exposing (Size)
import Svg exposing (Svg)
import Svg.Attributes as Attributes
import Triangle2d


drawing : Size units -> Svg msg
drawing size =
    let
        maxX =
            Quantity.half <| Size.width size

        maxY =
            Quantity.half <| Size.height size

        minX =
            Quantity.negate maxX

        minY =
            Quantity.negate maxY

        triangle =
            Triangle2d.from
                (Point2d.xy minX minY)
                (Point2d.xy Quantity.zero maxY)
                (Point2d.xy maxX minY)
    in
    Geometry.Svg.triangle2d
        [ Attributes.fill "orange" ]
        triangle


boundingBoxFromSize : Size units -> BoundingBox2d units coordinates
boundingBoxFromSize size =
    let
        topRight =
            Point2d.xy
                (Quantity.half <| Size.width size)
                (Quantity.half <| Size.height size)

        bottomLeft =
            Point2d.rotateAround Point2d.origin (Angle.radians pi) topRight
    in
    BoundingBox2d.from topRight bottomLeft
