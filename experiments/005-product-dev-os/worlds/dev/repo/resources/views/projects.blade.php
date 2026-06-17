{{-- Project list view. Server-rendered Blade (no SPA framework, ADR 0004). --}}
@extends('layouts.app')
@section('content')
  <h1>Projects for {{ $client->name }}</h1>
  <ul>
    @foreach ($projects as $project)
      <li>{{ $project->name }} ({{ $project->status }})</li>
    @endforeach
  </ul>
@endsection
