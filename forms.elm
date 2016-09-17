module Main exposing (..)

import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String
import Regex exposing (regex)


main : Program Never
main =
    App.beginnerProgram { model = model, view = view, update = update }



-- MODEL


type alias Model =
    { name : String
    , age : Maybe Int
    , gender : Gender
    , password : String
    , passwordAgain : String
    , acceptsTerms : Bool
    , submitted : Bool
    }


type Gender
    = Undisclosed
    | Male
    | Female


model : Model
model =
    { name = ""
    , age = Nothing
    , gender = Undisclosed
    , password = ""
    , passwordAgain = ""
    , acceptsTerms = False
    , submitted = False
    }



-- UPDATE


type Msg
    = Name String
    | Age String
    | SetGender Gender
    | Password String
    | PasswordAgain String
    | AcceptTermsToggle
    | Submit


update : Msg -> Model -> Model
update msg model =
    case msg of
        Name name ->
            { model | name = name }

        Age ageStr ->
            { model | age = Result.toMaybe (String.toInt ageStr) }

        SetGender gender ->
            { model | gender = gender }

        Password password ->
            { model | password = password }

        PasswordAgain password ->
            { model | passwordAgain = password }

        AcceptTermsToggle ->
            { model | acceptsTerms = not model.acceptsTerms }

        Submit ->
            { model | submitted = True }



-- VIEW


checkbox : msg -> String -> Bool -> Html msg
checkbox msg annotation selected =
    label
        [ style [ ( "padding", "20px" ) ]
        ]
        [ input [ type' "checkbox", onClick msg, checked selected ] []
        , text annotation
        ]


radio : msg -> String -> Bool -> Html msg
radio msg annotation selected =
    label
        [ style [ ( "padding", "20px" ) ]
        ]
        [ input [ type' "radio", name "font-size", onClick msg, checked selected ] []
        , text annotation
        ]


view : Model -> Html Msg
view model =
    div []
        [ div [] [ input [ type' "text", placeholder "Name", onInput Name ] [] ]
        , div [] [ input [ type' "text", placeholder "Age", onInput Age ] [] ]
        , div [] [ text "Gender:", genderSelection model ]
        , div []
            [ input [ type' "password", placeholder "Password", onInput Password ] []
            , input [ type' "password", placeholder "Re-enter Password", onInput PasswordAgain ] []
            ]
        , div [] [ checkbox AcceptTermsToggle "I accept the terms and conditions" model.acceptsTerms ]
        , div [] [ button [ type' "submit", onClick Submit ] [ text "Submit" ] ]
        , if model.submitted then
            viewValidation model
          else
            span [] []
        ]


genderSelection : Model -> Html Msg
genderSelection model =
    span []
        [ radio (SetGender Undisclosed) "Undisclosed" (model.gender == Undisclosed)
        , radio (SetGender Male) "Male" (model.gender == Male)
        , radio (SetGender Female) "Female" (model.gender == Female)
        ]


minAge : Int
minAge =
    18


viewValidation : Model -> Html msg
viewValidation model =
    let
        uppercaseRegex : Regex.Regex
        uppercaseRegex =
            regex "[A-Z]+"

        ( color, message ) =
            if not model.acceptsTerms then
                ( "maroon", "You must accept the terms and conditions first" )
            else if model.gender == Undisclosed then
                ( "purple", "Sorry, we really really want to know your gender" )
            else if Maybe.withDefault True (Maybe.map (\a -> a < minAge) model.age) then
                ( "turquoise", "Your age must be greater than " ++ (toString minAge) )
            else if not (Regex.contains uppercaseRegex model.password) then
                ( "orange", "Your password does not contain an upper case letter" )
            else if (String.length model.password) < 8 then
                ( "yellow", "Your password is less than 8 characters" )
            else if model.password /= model.passwordAgain then
                ( "red", "Passwords do not match!" )
            else
                ( "green", "OK" )
    in
        div [ style [ ( "background-color", color ) ] ] [ text message ]
