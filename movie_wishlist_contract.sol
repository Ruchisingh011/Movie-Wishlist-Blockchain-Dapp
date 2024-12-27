// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MovieWishlist {
    // Struct to represent a movie in the wishlist
    struct Movie {
        string title;
        string genre;
        uint256 year;
        address owner;
        bool watched;
        uint256 likes;
    }

    // Events to track important actions
    event MovieAdded(uint256 indexed movieId, string title, address indexed owner);
    event MovieWatched(uint256 indexed movieId, address indexed viewer);
    event MovieLiked(uint256 indexed movieId, address indexed liker);

    // Mapping to store movies
    mapping(uint256 => Movie) public movies;
    mapping(address => uint256[]) public userMovies;
    mapping(uint256 => mapping(address => bool)) public hasLiked;

    // Counter for movie IDs
    uint256 public movieCount;

    // Function to add a new movie to the wishlist
    function addMovie(string memory _title, string memory _genre, uint256 _year) public returns (uint256) {
        require(bytes(_title).length > 0, "Movie title cannot be empty");
        
        // Create new movie ID
        movieCount++;
        
        // Create new movie
        movies[movieCount] = Movie({
            title: _title,
            genre: _genre,
            year: _year,
            owner: msg.sender,
            watched: false,
            likes: 0
        });
        
        // Add movie to user's list
        userMovies[msg.sender].push(movieCount);
        
        // Emit event
        emit MovieAdded(movieCount, _title, msg.sender);
        
        return movieCount;
    }

    // Function to mark a movie as watched
    function markMovieAsWatched(uint256 _movieId) public {
        require(_movieId > 0 && _movieId <= movieCount, "Invalid movie ID");
        require(movies[_movieId].owner == msg.sender, "Only movie owner can mark as watched");
        require(!movies[_movieId].watched, "Movie already marked as watched");
        
        movies[_movieId].watched = true;
        
        emit MovieWatched(_movieId, msg.sender);
    }

    // Function to like a movie
    function likeMovie(uint256 _movieId) public {
        require(_movieId > 0 && _movieId <= movieCount, "Invalid movie ID");
        require(!hasLiked[_movieId][msg.sender], "You have already liked this movie");
        
        movies[_movieId].likes++;
        hasLiked[_movieId][msg.sender] = true;
        
        emit MovieLiked(_movieId, msg.sender);
    }

    // Function to get all movies for a user
    function getUserMovies(address _user) public view returns (uint256[] memory) {
        return userMovies[_user];
    }

    // Function to get movie details
    function getMovieDetails(uint256 _movieId) public view returns (
        string memory title, 
        string memory genre, 
        uint256 year, 
        address owner, 
        bool watched, 
        uint256 likes
    ) {
        require(_movieId > 0 && _movieId <= movieCount, "Invalid movie ID");
        
        Movie memory movie = movies[_movieId];
        return (
            movie.title, 
            movie.genre, 
            movie.year, 
            movie.owner, 
            movie.watched, 
            movie.likes
        );
    }

    // Function to get total number of unwatched movies
    function getUnwatchedMoviesCount() public view returns (uint256) {
        uint256 unwatchedCount = 0;
        for (uint256 i = 1; i <= movieCount; i++) {
            if (!movies[i].watched) {
                unwatchedCount++;
            }
        }
        return unwatchedCount;
    }
}