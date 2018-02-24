//
//  NowPlayingViewController.swift
//  flix_demo
//
//  Created by Sijin Wang on 2/14/18.
//  Copyright © 2018 Sijin Wang. All rights reserved.
//

import UIKit
import AlamofireImage

class NowPlayingViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var movies: [[String: Any]] = [];
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        activityIndicator.startAnimating()
        super.viewDidLoad()
        
        tableView.dataSource = self
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(NowPlayingViewController.didPullToRefresh(_:)), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
//        tableView.estimatedRowHeight = 100
//        tableView.rowHeight = UITableViewAutomaticDimension
        fetchMovies()
    }
    
    @objc func didPullToRefresh(_ refreshControl: UIRefreshControl) {
        fetchMovies()
    }
    
    func fetchMovies() {
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")!;
        let request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 10);
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main);
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription);
            }
            else if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any];
                //                print(dataDictionary);
                let movies = dataDictionary["results"] as! [[String: Any]];
                self.movies = movies;
                self.tableView.reloadData();
                self.refreshControl.endRefreshing()
            }
        }
        task.resume();
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count;
//        return 10;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath);
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell;
        let movie = movies[indexPath.row];
        let title = movie["title"] as! String;
        let overview = movie["overview"] as! String;
//        print(overview);
        cell.titleLabel.text = title;
        cell.overviewLabel.text = overview;
        //        print(cell.overviewLabel.text!);
        
        if let posterPathString = movie["poster_path"] as? String {
            let posterBaseUrl = "https://image.tmdb.org/t/p/w500";
            let posterUrl = URL(string: posterBaseUrl + posterPathString)!;
            cell.posterImageView.af_setImage(withURL: posterUrl);
        }
        else {
            cell.posterImageView.image = nil;
        }
        
        activityIndicator.stopAnimating()
        return cell;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
