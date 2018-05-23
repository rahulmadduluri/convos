package api

import (
	"net/http"

	"db"
	"middleware"

	"github.com/gorilla/mux"
)

func Search(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	userUUID := middleware.GetUUIDFromHeader(r.Header)
	searchText, _ := vars[_paramSearchText]

	groups, err := db.GetHandler().GetGroups(userUUID, searchText)
	if err != nil {
		respondWithError(w, http.StatusInternalServerError, "search: failed to get groups")
	} else {
		respondWithJSON(w, http.StatusOK, groups)
	}
}
