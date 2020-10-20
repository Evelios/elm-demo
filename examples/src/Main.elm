module Main exposing (..)

import Demo
import Element
import Geometry.Svg
import Point2d
import Quantity
import Size exposing (Size)
import Svg exposing (Svg)
import Svg.Attributes as Attributes
import Triangle2d


main =
    Demo.sandbox
        { generator = drawing
        , size = Demo.fullScreen
        , init = init
        , update = update
        , gui = \_ -> Element.none
        }


type alias Model =
    {}



-- Init


init : Model
init =
    {}



-- Update


type Msg
    = None


update : Msg -> Model -> Model
update msg model =
    case msg of
        None ->
            model



-- Drawing


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
