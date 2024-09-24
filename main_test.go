package main

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

const (
	successString string = "Successfully added!\n"
)

func TestRegister(t *testing.T) {
	// NOTE: I allow space in the address, so scripts are easier
	body := bytes.NewBufferString("{\"name\":\"Testdevice\",\"id\":\"123456789\",\"address\":\"192.168.100.151 \"}")
	req, err := http.NewRequest("POST", "/api/register", body)
	if err != nil {
		t.Fatal(err)
	}

	req.Header.Add("Content-Type", "application/json")
	req.RemoteAddr = "80.2.3.41:321"

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(RegisterDevice)

	// Our handlers satisfy http.Handler, so we can call their ServeHTTP method
	// directly and pass in our Request and ResponseRecorder.
	handler.ServeHTTP(rr, req)

	// Check the status code is what we expect.
	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v - %v",
			status, rr.Body)
	}

	// Check the response body is what we expect.
	if rr.Body.String() != successString {
		t.Errorf("handler returned unexpected body: got %v want %v", rr.Body.String(), successString)
	}
}

func TestRegisterWithTags(t *testing.T) {

	type Device struct {
		Name    string            `json:"name"`
		Id      string            `json:"id"`
		Address string            `json:"address"`
		Tags    map[string]string `json:"tags"`
	}

	d := Device{
		Name:    "test device",
		Id:      "123456789",
		Address: "192.168.1.143",
		Tags: map[string]string{
			"tag_0": "test_0",
			"tag_1": "test_1",
		},
	}
	var body bytes.Buffer
	if err := json.NewEncoder(&body).Encode(d); err != nil {
		t.Fatal(err)
	}
	req, err := http.NewRequest("POST", "/api/register", &body)
	if err != nil {
		t.Fatal(err)
	}

	req.Header.Add("Content-Type", "application/json")
	req.RemoteAddr = "80.2.3.41:321"

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(RegisterDevice)

	handler.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v - %v",
			status, rr.Body)
	}

	// Check the response body is what we expect.
	if rr.Body.String() != successString {
		t.Errorf("handler returned unexpected body: got %v want %v", rr.Body.String(), successString)
	}
}

func TestList(t *testing.T) {
	req, err := http.NewRequest("GET", "/api/devices", nil)
	if err != nil {
		t.Fatal(err)
	}

	req.RemoteAddr = "80.2.3.41:321"

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(ListDevices)

	handler.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v - %v", status, rr.Body)
	}

	if !strings.HasPrefix(rr.Body.String(), `[{"address":"192.168.1.143","id":"123456789","name":"test device","tags":{"tag_0":"test_0","tag_1":"test_1"},"added"`) {
		t.Errorf("handler returned unexpected body: got %v", rr.Body.String())
	}
}

func TestInvalidAccess(t *testing.T) {
	req, err := http.NewRequest("GET", "/api/devices", nil)
	if err != nil {
		t.Fatal(err)
	}

	req.RemoteAddr = "80.2.3.42:321"

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(ListDevices)

	handler.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v - %v", status, rr.Body)
	}

	if rr.Body.String() != "[]\n" {
		t.Errorf("handler returned unexpected body: got %v", rr.Body.String())
	}
}

func TestLoopbackAddress(t *testing.T) {
	body := bytes.NewBufferString("{\"name\":\"Testdevice\",\"address\":\"127.0.0.1 \"}")
	req, err := http.NewRequest("POST", "/api/register", body)
	if err != nil {
		t.Fatal(err)
	}

	req.Header.Add("Content-Type", "application/json")
	req.RemoteAddr = "80.2.3.41:321"

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(RegisterDevice)

	handler.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusBadRequest {
		t.Errorf("handler returned wrong status code: got %v - %v",
			status, rr.Body)
	}
}

func TestNonIP(t *testing.T) {
	body := bytes.NewBufferString("{\"name\":\"Testdevice\",\"address\":\"192.168.300 \"}")
	req, err := http.NewRequest("POST", "/api/register", body)
	if err != nil {
		t.Fatal(err)
	}

	req.Header.Add("Content-Type", "application/json")
	req.RemoteAddr = "80.2.3.41:321"

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(RegisterDevice)

	handler.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusBadRequest {
		t.Errorf("handler returned wrong status code: got %v - %v",
			status, rr.Body)
	}
}

func TestIPv6(t *testing.T) {
	body := bytes.NewBufferString("{\"name\":\"Testdevice\",\"address\":\"2001:db8:a0b:12f0::1 \"}")
	req, err := http.NewRequest("POST", "/api/register", body)
	if err != nil {
		t.Fatal(err)
	}

	req.Header.Add("Content-Type", "application/json")
	req.RemoteAddr = "80.2.3.41:321"

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(RegisterDevice)

	handler.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v - %v",
			status, rr.Body)
	}
}

func TestIPv6URL(t *testing.T) {
	body := bytes.NewBufferString("{\"name\":\"Testdevice\",\"address\":\"[2001:db8:a0b:12f0::1]\"}")
	req, err := http.NewRequest("POST", "/api/register", body)
	if err != nil {
		t.Fatal(err)
	}

	req.Header.Add("Content-Type", "application/json")
	req.RemoteAddr = "80.2.3.41:321"

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(RegisterDevice)

	handler.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusBadRequest {
		t.Errorf("handler returned wrong status code: got %v - %v",
			status, rr.Body)
	}
}
