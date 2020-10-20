module Render exposing (cartesian)

{-| Utility functions to support rendering svg images.

@docs cartesian

-}

import Html exposing (Html)
import Quantity
import Size exposing (Size)
import Svg exposing (Svg)
import Svg.Attributes


{-| -}
cartesian : Size units -> Svg msg -> Html msg
cartesian size svg =
    let
        viewBox =
            [ Size.width size
                |> Quantity.half
                |> Quantity.negate
                |> Quantity.unwrap
                |> ceiling
                |> String.fromInt
            , Size.height size
                |> Quantity.half
                |> Quantity.negate
                |> Quantity.unwrap
                |> ceiling
                |> String.fromInt
            , Size.width size
                |> Quantity.unwrap
                |> floor
                |> String.fromInt
            , Size.height size
                |> Quantity.unwrap
                |> floor
                |> String.fromInt
            ]
                |> String.join " "
    in
    Svg.svg
        [ Svg.Attributes.viewBox viewBox
        ]
        [ svg
        ]
