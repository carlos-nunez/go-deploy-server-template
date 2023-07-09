package main

import (
	"context"
	"fmt"
	"net/http"
	"os"

	API "github.com/carlos-nunez/go-api-template/api"
	"github.com/carlos-nunez/go-api-template/middleware"
	"github.com/gorilla/handlers"
	"github.com/gorilla/mux"
	"github.com/joho/godotenv"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"go.mongodb.org/mongo-driver/mongo/readpref"
)

var (
	api    = API.NewAPI()
	mdb    mongo.Database
	router *mux.Router
	ctx    context.Context
)

func setupAPI() {
	create := router.Methods("POST").PathPrefix("/api").Subrouter()
	delete := router.Methods("DELETE").PathPrefix("/api").Subrouter()

	create.HandleFunc("/deploy", middleware.Auth(api.DeployWSServer))
	delete.HandleFunc("/deploy", middleware.Auth(api.DestroyWSServer))

	fmt.Println("Finished Setting Up API")
}

func setupMongo() {
	if err := godotenv.Load(); err != nil {
		fmt.Println("No Env File")
	}

	uri := os.Getenv("MONGO_URI")

	if len(uri) == 0 {
		panic("No MongoURI")
	}

	ctx = context.TODO()

	client, err := mongo.Connect(ctx, options.Client().ApplyURI(uri))
	if err != nil {
		panic(err)
	}

	database := os.Getenv("PRODUCT")
	db := client.Database(database)
	mdb = *db

	// Ping the primary
	if err := client.Ping(ctx, readpref.Primary()); err != nil {
		panic(err)
	}

	fmt.Println("Successfully Connected to MongoDB")
}

func main() {
	router = mux.NewRouter()

	setupMongo()
	api.Initialize(mdb, ctx)
	setupAPI()

	corsOrigins := handlers.AllowedOrigins([]string{"http://localhost:3000", "http://localhost:5000"})
	corsMethods := handlers.AllowedMethods([]string{"GET", "POST", "PUT", "DELETE"})
	corsHeaders := handlers.AllowedHeaders([]string{"Content-Type", "Authorization"})

	corsHandler := handlers.CORS(corsOrigins, corsMethods, corsHeaders)(router)

	http.ListenAndServe(":6000", corsHandler)
}
