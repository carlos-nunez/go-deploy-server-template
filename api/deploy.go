package api

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"os/exec"

	"github.com/carlos-nunez/go-api-template/model"
	"go.mongodb.org/mongo-driver/bson"
)

func (a API) DeployWSServer(w http.ResponseWriter, r *http.Request) {
	var server model.WebsocketServer

	err := a.marshallBody(&server, w, r)
	if err != nil {
		http.Error(w, err.Error(), 500)
		return
	}
	fmt.Println("Deploying WS Server: " + server.UUID)

	go a.deployWSServer(server)
	server.Status = "In-Progress"
	update := bson.M{"$set": bson.M{"status": "In-Progress"}}
	_, err = a.mdb.Collection("servers").UpdateOne(a.ctx, bson.D{{Key: "_id", Value: server.ID}}, update)

	js, err := json.Marshal(server)

	w.Header().Set("Content-Type", "application/json")
	w.Write(js)
}

func (a API) DestroyWSServer(w http.ResponseWriter, r *http.Request) {
	var server model.WebsocketServer

	err := a.marshallBody(&server, w, r)
	if err != nil {
		http.Error(w, err.Error(), 500)
		return
	}

	fmt.Println("Destoying WS Server: " + server.UUID)

	go a.destroyWSServer(server)
	server.Status = "Destroy In-Progress"
	update := bson.M{"$set": bson.M{"status": "Destroy In-Progress"}}
	_, err = a.mdb.Collection("servers").UpdateOne(a.ctx, bson.D{{Key: "_id", Value: server.ID}}, update)

	js, err := json.Marshal(server)

	w.Header().Set("Content-Type", "application/json")
	w.Write(js)
}

func (a API) deployWSServer(server model.WebsocketServer) {
	dir := fmt.Sprintf("terraform/environments/%s", server.UUID)
	_, err := exec.Command("mkdir", "-p", dir).Output()
	if err != nil {
		a.handleDeployError(server, err)
		return
	}

	os.Chdir("terraform/baseline")
	_, err = exec.Command("terraform", "init").Output()
	os.Chdir("../../")

	_, err = exec.Command("cp", "-R", "terraform/environments/template/", dir).Output()
	if err != nil {
		a.handleDeployError(server, err)
		return
	}

	os.Chdir(dir)
	_, err = exec.Command("terraform", "init").Output()
	if err != nil {
		a.handleDeployError(server, err)
		return
	}

	cmd := exec.Command("terraform", "apply", "-auto-approve", "-var", "uuid="+server.UUID, "-var", "api_key="+server.ApiToken, "-var-file=../terraform.tfvars")
	_, err = cmd.Output()
	if err != nil {
		a.handleDeployError(server, err)
		return
	}

	update := bson.M{"$set": bson.M{"status": "Online"}}
	_, err = a.mdb.Collection("servers").UpdateOne(a.ctx, bson.D{{Key: "_id", Value: server.ID}}, update)

	os.Chdir("../../../")
	cmd = exec.Command("git", "pull")
	_, err = cmd.Output()
	cmd = exec.Command("git", "add", ".")
	_, err = cmd.Output()
	cmd = exec.Command("git", "commit", "-m", "Deployed Server: "+server.UUID)
	_, err = cmd.Output()
	cmd = exec.Command("git", "push")
	_, err = cmd.Output()
}

func (a API) destroyWSServer(server model.WebsocketServer) {
	dir := fmt.Sprintf("terraform/environments/%s", server.UUID)
	os.Chdir(dir)

	cmd := exec.Command("terraform", "destroy", "-auto-approve", "-var", "uuid="+server.UUID, "-var", "api_key="+server.ApiToken, "-var-file=../terraform.tfvars")
	_, err := cmd.Output()
	if err != nil {
		a.handleDestroyError(server, err)
		return
	}

	update := bson.M{"$set": bson.M{"status": "Destroyed"}}
	_, err = a.mdb.Collection("servers").UpdateOne(a.ctx, bson.D{{Key: "_id", Value: server.ID}}, update)

	os.Chdir("../../../")
	cmd = exec.Command("git", "pull")
	_, err = cmd.Output()
	cmd = exec.Command("git", "add", ".")
	_, err = cmd.Output()
	cmd = exec.Command("git", "commit", "-m", "Destroyed Server: "+server.UUID)
	_, err = cmd.Output()
	cmd = exec.Command("git", "push")
	_, err = cmd.Output()
}

func (a API) handleDeployError(server model.WebsocketServer, erro error) {
	update := bson.M{"$set": bson.M{"status": "Failed"}}
	_, err := a.mdb.Collection("servers").UpdateOne(a.ctx, bson.D{{Key: "_id", Value: server.ID}}, update)
	if err != nil {
	}
}

func (a API) handleDestroyError(server model.WebsocketServer, erro error) {
	update := bson.M{"$set": bson.M{"status": "Destroy Failed"}}
	_, err := a.mdb.Collection("servers").UpdateOne(a.ctx, bson.D{{Key: "_id", Value: server.ID}}, update)
	if err != nil {
	}
}
