package middleware

import (
	"encoding/json"
	"errors"
	"log"
	"net/http"
	"os"
	"strings"

	jwtmiddleware "github.com/auth0/go-jwt-middleware"
	jwt "github.com/dgrijalva/jwt-go"
)

type CustomClaims struct {
	uuidClaims UUIDClaims
	jwt.StandardClaims
}

type UUIDClaims struct {
	UUID string `json:"https://zebi.com/uuid,omitempty"`
}

type Jwks struct {
	Keys []JSONWebKeys `json:"keys"`
}

type JSONWebKeys struct {
	Kty string   `json:"kty"`
	Kid string   `json:"kid"`
	Use string   `json:"use"`
	N   string   `json:"n"`
	E   string   `json:"e"`
	X5c []string `json:"x5c"`
}

func JWTMiddleware() *jwtmiddleware.JWTMiddleware {
	return jwtmiddleware.New(jwtmiddleware.Options{
		ValidationKeyGetter: func(token *jwt.Token) (interface{}, error) {
			// Verify 'aud' claim
			aud := os.Getenv("JWT_AUDIENCE")
			checkAud := token.Claims.(jwt.MapClaims).VerifyAudience(aud, false)
			if !checkAud {
				return token, errors.New("Invalid audience.")
			}
			// Verify 'iss' claim
			iss := "https://" + os.Getenv("AUTH0_DOMAIN") + "/"
			checkIss := token.Claims.(jwt.MapClaims).VerifyIssuer(iss, false)
			if !checkIss {
				return token, errors.New("Invalid issuer.")
			}

			cert, err := getPemCert(token)
			if err != nil {
				panic(err.Error())
			}

			result, _ := jwt.ParseRSAPublicKeyFromPEM([]byte(cert))
			return result, nil
		},
		SigningMethod: jwt.SigningMethodRS256,
	})
}

// Negroni function that checks if user has UUID
func HandlerForUUIDWithNext(w http.ResponseWriter, r *http.Request, next http.HandlerFunc) {
	authHeaderParts := strings.Split(r.Header.Get("Authorization"), " ")
	tokenString := authHeaderParts[1]
	token, _ := jwt.ParseWithClaims(tokenString, &CustomClaims{}, nil)
	claims, _ := token.Claims.(*CustomClaims)

	hasUUID := false
	log.Println("GETTING UUID")
	log.Println(claims)
	log.Println(r.Header.Get("x-uuid"))
	// claims.UUID comes from key specified in Auth0
	if claims.uuidClaims.UUID == r.Header.Get("x-uuid") && r.Header.Get("x-uuid") != "" {
		log.Println("Has UUID")
		log.Println(r.Header.Get("x-uuid"))
		hasUUID = true
	}

	// If client has UUID.
	if hasUUID == true {
		next(w, r)
	}
}

func getPemCert(token *jwt.Token) (string, error) {
	cert := ""
	resp, err := http.Get("https://" + os.Getenv("AUTH0_DOMAIN") + "/.well-known/jwks.json")

	if err != nil {
		return cert, err
	}
	defer resp.Body.Close()

	var jwks = Jwks{}
	err = json.NewDecoder(resp.Body).Decode(&jwks)

	if err != nil {
		return cert, err
	}

	x5c := jwks.Keys[0].X5c
	for k, v := range x5c {
		if token.Header["kid"] == jwks.Keys[k].Kid {
			cert = "-----BEGIN CERTIFICATE-----\n" + v + "\n-----END CERTIFICATE-----"
		}
	}

	if cert == "" {
		err := errors.New("Unable to find appropriate key.")
		return cert, err
	}

	return cert, nil
}
